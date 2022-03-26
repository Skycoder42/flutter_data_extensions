import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';

import '../firebase_database_adapter.dart';
import '../serialization/firebase_value_transformer.dart';
import 'database_event.dart';
import 'errors/authentication_revoked.dart';
import 'errors/remote_cancellation.dart';
import 'event_stream/database_event_stream.dart';

typedef UnsupportedEventCb = void Function(String event, String? path);

@internal
class StreamAllController<T extends DataModel<T>> {
  static const _rootPath = '/';

  static final _subPathRegexp = RegExp(r'^\/([^\/]+)$');

  final Future<DatabaseEventStream> Function() createStream;
  final FirebaseDatabaseAdapter<T> adapter;
  final bool syncLocal;
  final bool autoRenew;
  final UnsupportedEventCb? onUnsupportedEvent;

  // ignore: cancel_subscriptions
  StreamSubscription<void>? _databaseEventSub;
  late final _streamController = StreamController<List<T>>(
    onListen: _onListen,
    onPause: _onPause,
    onResume: _onResume,
    onCancel: _onCancel,
  );

  var _streamState = <T>[];

  StreamAllController({
    required this.createStream,
    required this.adapter,
    this.syncLocal = false,
    this.autoRenew = true,
    this.onUnsupportedEvent,
  });

  Stream<List<T>> get stream => _streamController.stream;

  void _onListen() {
    _databaseEventSub = Stream.fromFuture(createStream())
        .asyncExpand((stream) => stream)
        .listen(
          _onEvent,
          onError: _streamController.addError,
          onDone: _streamController.close,
          // If desired, errors will cancel via the controller
          cancelOnError: false,
        );
  }

  void _onPause() {
    _databaseEventSub?.pause();
  }

  void _onResume() {
    _databaseEventSub?.resume();
  }

  Future<void> _onCancel({bool closeController = true}) async {
    try {
      final sub = _databaseEventSub;
      _databaseEventSub = null;
      await sub?.cancel();
    } finally {
      if (closeController && !_streamController.isClosed) {
        await _streamController.close();
      }
    }
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
      _onCancel(closeController: false).catchError(_streamController.addError);
      _onListen();
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
