import 'dart:async';

import 'package:flutter_data/flutter_data.dart';

import '../../flutter_data_firebase_database.dart';
import '../serialization/firebase_value_transformer.dart';
import 'database_event.dart';
import 'database_event_stream.dart';
import 'errors/authentication_revoked.dart';
import 'errors/remote_cancellation.dart';

typedef UnsupportedEventCb = void Function(String event, String? path);

class StreamAllController<T extends DataModel<T>> {
  static const _rootPath = '/';

  static final _subPathRegexp = RegExp(r'^\/([^\/]+)$');

  final Future<DatabaseEventStream> Function() createStream;
  final FirebaseDatabaseAdapter<T> adapter;
  final bool syncLocal;
  final bool autoRenew;
  final UnsupportedEventCb? onUnsupportedEvent;

  late final StreamController<List<T>> _streamController;
  // ignore: cancel_subscriptions
  StreamSubscription<void>? _databaseEventSub;

  var _streamState = <T>[];

  StreamAllController({
    required this.createStream,
    required this.adapter,
    this.syncLocal = false,
    this.autoRenew = true,
    this.onUnsupportedEvent,
  }) {
    _streamController = StreamController<List<T>>(
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }

  Stream<List<T>> get stream => _streamController.stream;

  Future<void> _onListen() async {
    final stream = await createStream();
    // pass _onEvent as map instead of listen to handle asynchronous processing
    _databaseEventSub = stream.listen(
      _onEvent,
      onError: _streamController.addError,
      onDone: _streamController.close,
      // If desired, errors will cancel via the controller
      cancelOnError: false,
    );
  }

  FutureOr<void> _onCancel() {
    final sub = _databaseEventSub;
    _databaseEventSub = null;
    return sub?.cancel();
  }

  void _onEvent(DatabaseEvent event) => event.when(
        put: _put,
        patch: _patch,
        keepAlive: _keepAlive,
        cancel: _cancel,
        authRevoked: _authRevoked,
      );

  void _put(DatabaseEventData data) =>
      data.path == _rootPath ? _reset(data) : _update(data);

  void _reset(DatabaseEventData data) {
    if (syncLocal) {
      adapter.clear();
    }
    final deserialized = adapter.deserialize(
      FirebaseValueTransformer.transformAll(data.data),
    );

    _replaceState(deserialized.models);
  }

  void _update(DatabaseEventData data) {
    final match = _subPathRegexp.firstMatch(data.path);
    if (match != null) {
      if (data.data != null) {
        final deserialized = adapter.deserialize(
          FirebaseValueTransformer.transformOne(data.data, match[1]),
        );
        _updateState(deserialized.model!);
      } else {
        _removeState(match[1]!);
      }
    } else {
      onUnsupportedEvent?.call('put', data.path);
    }
  }

  void _patch(DatabaseEventData data) {
    if (data.path != _rootPath) {
      onUnsupportedEvent?.call('patch', data.path);
      return;
    }

    final eventData = data.data;
    if (eventData is Map<String, dynamic>) {
      eventData.entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .forEach((key) => _removeState(key, false));
    }

    final deserialized = adapter.deserialize(
      FirebaseValueTransformer.transformAll(data.data),
    );

    for (final model in deserialized.models) {
      _updateState(model, false);
    }
    _streamController.add(_streamState);
  }

  void _keepAlive() => onUnsupportedEvent?.call('keep-alive', null);

  void _cancel(String reason) {
    _streamController.addError(RemoteCancellation(reason));
  }

  void _authRevoked() {
    if (autoRenew) {
      _onCancel(); // TODO handle errors?
      _onListen(); // TODO handle async
    } else {
      _streamController.addError(AuthenticationRevoked(), StackTrace.current);
    }
  }

  void _replaceState(List<T> newState) {
    _streamState = newState;
    _streamController.add(_streamState);
  }

  void _updateState(T data, [bool addEvent = true]) {
    final dataIndex =
        _streamState.indexWhere((element) => element.id == data.id);
    if (dataIndex == -1) {
      _streamState.add(data);
    } else {
      _streamState[dataIndex] = data;
    }

    if (addEvent) {
      _streamController.add(_streamState);
    }
  }

  void _removeState(Object id, [bool addEvent = true]) {
    adapter.delete(id, remote: false);
    _streamState.removeWhere((element) => element.id == id);
    if (addEvent) {
      _streamController.add(_streamState);
    }
  }
}
