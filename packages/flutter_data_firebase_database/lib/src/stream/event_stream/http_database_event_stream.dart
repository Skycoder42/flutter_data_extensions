import 'dart:async';

import 'package:eventsource/eventsource.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../database_event.dart';

@internal
class DatabaseEventStream extends Stream<DatabaseEvent> {
  final Uri uri;
  final Map<String, String>? headers;
  final Client? client;

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
  }) =>
      Stream.fromFuture(
        EventSource.connect(
          uri,
          headers: headers,
          client: client,
        ),
      )
          .asyncExpand((eventSource) => eventSource)
          .map(_mapEventToDatabaseEvent)
          .listen(
            onData,
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError,
          );

  static DatabaseEvent _mapEventToDatabaseEvent(Event event) {
    switch (event.event) {
      case 'put':
        return DatabaseEvent.put(
          DatabaseEventData.fromRawJson(event.data!),
        );
      case 'patch':
        return DatabaseEvent.patch(
          DatabaseEventData.fromRawJson(event.data!),
        );
      case 'keep-alive':
        return const DatabaseEvent.keepAlive();
      case 'cancel':
        return DatabaseEvent.cancel(event.data ?? '');
      case 'auth_revoked':
        return const DatabaseEvent.authRevoked();
      default:
        throw ArgumentError.value(
          event,
          'event',
          'Unknown firebase event type',
        );
    }
  }
}
