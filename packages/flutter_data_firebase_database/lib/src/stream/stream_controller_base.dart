import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';

import '../firebase_database_adapter.dart';
import 'database_event.dart';
import 'errors/authentication_revoked.dart';
import 'errors/remote_cancellation.dart';

typedef UnsupportedEventCb = void Function(String event, String? path);

@internal
abstract class StreamControllerBase<TModel extends DataModel<TModel>, TStream> {
  static const rootPath = '/';

  final Future<Stream<DatabaseEvent>> Function() createStream;
  final FirebaseDatabaseAdapter<TModel> adapter;
  final bool autoRenew;
  final UnsupportedEventCb? onUnsupportedEvent;

  // ignore: cancel_subscriptions
  StreamSubscription<void>? _databaseEventSub;
  late final _streamController = StreamController<TStream>(
    onListen: _onListen,
    // do not pause event source, as it might be a broadcast and
    // we do not want to miss any events
    onCancel: _onCancel,
  );

  StreamControllerBase({
    required this.createStream,
    required this.adapter,
    this.autoRenew = true,
    this.onUnsupportedEvent,
  });

  Stream<TStream> get stream => _streamController.stream;

  @protected
  Sink<TStream> get sink => _streamController.sink;

  void _onListen() {
    _databaseEventSub = Stream.fromFuture(createStream())
        .asyncExpand((stream) => stream)
        .asyncMap(_onEvent)
        .listen(
          // use asyncMap to listen to ensure events are processed sequentially
          null,
          onError: _streamController.addError,
          onDone: _streamController.close,
          // If desired, errors will cancel via the controller
          cancelOnError: false,
        );
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

  FutureOr<void> _onEvent(DatabaseEvent event) => event.when(
        put: put,
        patch: patch,
        keepAlive: _keepAlive,
        cancel: _cancel,
        authRevoked: _authRevoked,
      );

  @protected
  Future<void> put(DatabaseEventData data);

  @protected
  Future<void> patch(DatabaseEventData data);

  void _keepAlive() {}

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
}
