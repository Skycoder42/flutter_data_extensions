import 'dart:async';
import 'dart:html';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../database_event.dart';

@internal
class DatabaseEventStream extends Stream<DatabaseEvent> {
  final Uri uri;
  final Map<String, String>? headers;
  final dynamic client;

  DatabaseEventStream({
    required this.uri,
    this.headers,
    this.client,
  });

  @override
  StreamSubscription<DatabaseEvent> listen(
    void Function(DatabaseEvent event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final eventSource = createEventSource();

    final putStream =
        eventSource.on[DatabaseEvent.putEvent].cast<MessageEvent>().map(
              (event) => DatabaseEvent.put(
                DatabaseEventData.fromRawJson(event.data as String),
              ),
            );

    final patchStream =
        eventSource.on[DatabaseEvent.patchEvent].cast<MessageEvent>().map(
              (event) => DatabaseEvent.patch(
                DatabaseEventData.fromRawJson(event.data as String),
              ),
            );

    final keepAliveStream = eventSource.on[DatabaseEvent.keepAliveEvent]
        .cast<MessageEvent>()
        .map((event) => const DatabaseEvent.keepAlive());

    final cancelStream = eventSource.on[DatabaseEvent.cancelEvent]
        .cast<MessageEvent>()
        .map((event) => DatabaseEvent.cancel(event.data as String? ?? ''));

    final authRevokedStream = eventSource.on[DatabaseEvent.authRevokedEvent]
        .cast<MessageEvent>()
        .map((event) => const DatabaseEvent.authRevoked());

    final errorStream =
        eventSource.onError.cast<ErrorEvent>().map<DatabaseEvent>(
              // ignore: only_throw_errors
              (event) => throw event.error ?? Exception('Unknown Error'),
            );

    return MergeStream([
      putStream,
      patchStream,
      keepAliveStream,
      cancelStream,
      authRevokedStream,
      errorStream,
    ]).doOnCancel(() => eventSource.close()).listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  @visibleForTesting
  EventSource createEventSource() => EventSource(uri.toString());
}
