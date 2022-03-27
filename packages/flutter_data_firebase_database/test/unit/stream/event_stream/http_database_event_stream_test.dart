@TestOn('!browser')

import 'dart:async';
import 'dart:convert';

import 'package:dart_test_tools/test.dart';
import 'package:eventsource/eventsource.dart';
import 'package:flutter_data_firebase_database/src/stream/database_event.dart';
import 'package:flutter_data_firebase_database/src/stream/event_stream/http_database_event_stream.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

class MockClient extends Mock implements Client {}

class MockStreamedResponse extends Mock implements StreamedResponse {}

class TestableDatabaseEventStream extends DatabaseEventStream {
  final Stream<Event> eventSource;

  TestableDatabaseEventStream(this.eventSource) : super(uri: Uri());

  @override
  Future<Stream<Event>> createEventSource() async => eventSource;
}

void main() {
  setUpAll(() {
    registerFallbackValue(Request('GET', Uri()));
  });

  group('DatabaseEventStream (http)', () {
    test('expands created eventsource as stream', () {
      final event = Event(event: 'auth_revoked');
      final sut = TestableDatabaseEventStream(Stream.value(event));

      expect(
        sut,
        emitsInOrder(<dynamic>[
          const DatabaseEvent.authRevoked(),
          emitsDone,
        ]),
      );
    });

    testData<Tuple2<Event, DatabaseEvent>>(
      'correctly maps events',
      [
        Tuple2(
          Event(
            event: 'put',
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
        Tuple2(
          Event(
            event: 'patch',
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
        Tuple2(Event(event: 'keep-alive'), const DatabaseEvent.keepAlive()),
        Tuple2(
          Event(event: 'cancel', data: 'error'),
          const DatabaseEvent.cancel('error'),
        ),
        Tuple2(Event(event: 'auth_revoked'), const DatabaseEvent.authRevoked()),
      ],
      (fixture) {
        final sut = TestableDatabaseEventStream(Stream.value(fixture.item1));

        expect(
          sut,
          emitsInOrder(<dynamic>[
            fixture.item2,
            emitsDone,
          ]),
        );
      },
    );

    test('emits error for invalid events', () {
      final event = Event.message();
      final sut = TestableDatabaseEventStream(Stream.value(event));

      expect(
        sut,
        emitsInOrder(<dynamic>[
          emitsError(isArgumentError),
          emitsDone,
        ]),
      );
    });

    test('handles multiple events', () {
      final events = [
        Event(event: 'auth_revoked'),
        Event(event: 'cancel'),
        Event(event: 'keep-alive'),
        Event(event: 'auth_revoked'),
      ];
      final sut = TestableDatabaseEventStream(Stream.fromIterable(events));

      expect(
        sut,
        emitsInOrder(<dynamic>[
          const DatabaseEvent.authRevoked(),
          const DatabaseEvent.cancel(''),
          const DatabaseEvent.keepAlive(),
          const DatabaseEvent.authRevoked(),
          emitsDone,
        ]),
      );
    });

    test('createEventSource creates event source with correct arguments',
        () async {
      final mockClient = MockClient();
      final mockResponse = MockStreamedResponse();

      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.stream)
          .thenAnswer((i) => ByteStream.fromBytes([]));
      when(() => mockClient.send(any())).thenReturnAsync(mockResponse);

      final url = Uri.http('localhost', '/');
      const headers = {'a': '1'};

      final sut = DatabaseEventStream(
        uri: url,
        headers: headers,
        client: mockClient,
      );

      final stream = await sut.createEventSource();

      expect(stream, isA<EventSource>());
      final es = stream as EventSource;

      expect(es.url, url);
      expect(es.headers, headers);
      expect(es.client, mockClient);
    });
  });
}
