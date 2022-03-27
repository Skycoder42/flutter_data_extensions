@TestOn('browser')

import 'dart:convert';
import 'dart:html';

import 'package:dart_test_tools/test.dart';
import 'package:flutter_data_firebase_database/src/stream/database_event.dart';
import 'package:flutter_data_firebase_database/src/stream/event_stream/web_database_event_stream.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

// ignore: avoid_implementing_value_types
class MockEventSource extends Mock implements EventSource {}

class MockEvents extends Mock implements Events {}

class TestableDatabaseEventStream extends DatabaseEventStream {
  final MockEventSource mockEventSource;

  TestableDatabaseEventStream(this.mockEventSource) : super(uri: Uri());

  @override
  EventSource createEventSource() => mockEventSource;
}

void main() {
  group('DatabaseEventStream (web)', () {
    final mockEventSource = MockEventSource();
    final mockEvents = MockEvents();

    late TestableDatabaseEventStream sut;

    setUp(() {
      reset(mockEventSource);
      reset(mockEvents);

      when(() => mockEventSource.on).thenReturn(mockEvents);
      when(() => mockEvents[any()]).thenStream(const Stream.empty());
      when(() => mockEventSource.onError).thenStream(const Stream.empty());

      sut = TestableDatabaseEventStream(mockEventSource);
    });

    testData<Tuple3<String, MessageEvent, DatabaseEvent>>(
      'correctly maps events',
      [
        Tuple3(
          'put',
          MessageEvent(
            'put',
            data: json.encode({
              'path': '/event/path',
              'data': 42,
            }),
          ),
          const DatabaseEvent.put(
            DatabaseEventData(
              path: '/event/path',
              data: 42,
            ),
          ),
        ),
        Tuple3(
          'patch',
          MessageEvent(
            'patch',
            data: json.encode({
              'path': '/event/path',
              'data': {
                'a': 1,
              },
            }),
          ),
          const DatabaseEvent.patch(
            DatabaseEventData(
              path: '/event/path',
              data: {
                'a': 1,
              },
            ),
          ),
        ),
        Tuple3(
          'keep-alive',
          MessageEvent('keep-alive'),
          const DatabaseEvent.keepAlive(),
        ),
        Tuple3(
          'cancel',
          MessageEvent('cancel', data: 'error'),
          const DatabaseEvent.cancel('error'),
        ),
        Tuple3(
          'auth_revoked',
          MessageEvent('auth_revoked'),
          const DatabaseEvent.authRevoked(),
        ),
      ],
      (fixture) {
        when(() => mockEvents[fixture.item1])
            .thenStream(Stream.value(fixture.item2));

        expect(
          sut,
          emitsInOrder(<dynamic>[
            fixture.item3,
            emitsDone,
          ]),
        );
      },
    );

    test('forwards error events as stream errors', () {
      when(() => mockEventSource.onError).thenStream(
        Stream.value(
          ErrorEvent('error', <String, dynamic>{
            'error': Exception('error'),
          }),
        ),
      );

      expect(
        sut,
        emitsInOrder(<dynamic>[
          emitsError(isException),
          emitsDone,
        ]),
      );
    });

    test('correctly merges errors in original order', () {
      when(() => mockEvents[DatabaseEvent.authRevokedEvent]).thenStream(
        Stream.fromFutures([
          Future.value(MessageEvent(DatabaseEvent.authRevokedEvent)),
          Future.delayed(
            const Duration(milliseconds: 100),
            () => MessageEvent(DatabaseEvent.authRevokedEvent),
          ),
          Future.delayed(
            const Duration(milliseconds: 500),
            () => MessageEvent(DatabaseEvent.keepAliveEvent),
          ),
        ]),
      );

      when(() => mockEvents[DatabaseEvent.cancelEvent]).thenStream(
        Stream.fromFutures([
          Future.delayed(
            const Duration(milliseconds: 200),
            () => MessageEvent(DatabaseEvent.cancelEvent),
          ),
          Future.delayed(
            const Duration(milliseconds: 400),
            () => MessageEvent(DatabaseEvent.cancelEvent, data: 'abort'),
          ),
        ]),
      );

      when(() => mockEvents[DatabaseEvent.keepAliveEvent]).thenStream(
        Stream.fromFutures([
          Future.delayed(
            const Duration(milliseconds: 300),
            () => MessageEvent(DatabaseEvent.keepAliveEvent),
          ),
          Future.delayed(
            const Duration(milliseconds: 600),
            () => MessageEvent(DatabaseEvent.keepAliveEvent),
          ),
        ]),
      );

      expect(
        sut,
        emitsInOrder(<dynamic>[
          const DatabaseEvent.authRevoked(),
          const DatabaseEvent.authRevoked(),
          const DatabaseEvent.cancel(''),
          const DatabaseEvent.keepAlive(),
          const DatabaseEvent.cancel('abort'),
          const DatabaseEvent.authRevoked(),
          const DatabaseEvent.keepAlive(),
          emitsDone,
        ]),
      );
    });

    test('cancels eventsource when subscription is canceled', () async {
      when(() => mockEvents[DatabaseEvent.keepAliveEvent]).thenStream(
        Stream.periodic(
          const Duration(seconds: 1),
          (_) => MessageEvent(DatabaseEvent.keepAliveEvent),
        ),
      );

      final sub = sut.listen(null);
      await expectLater(sub.cancel(), completes);

      verify(() => mockEventSource.close());
    });
  });
}
