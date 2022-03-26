import 'package:eventsource/eventsource.dart';
import 'package:flutter_data_firebase_database/src/stream/event_stream/http_database_event_stream.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockEventSource extends Mock implements EventSource {}

class TestableDatabaseEventStream extends DatabaseEventStream {
  final MockEventSource mockEventSource;

  TestableDatabaseEventStream({
    required this.mockEventSource,
    required Uri uri,
    required Map<String, String>? headers,
    required Client? client,
  }) : super(
          uri: uri,
          headers: headers,
          client: client,
        );

  @override
  Future<EventSource> createEventSource() async => mockEventSource;
}

void main() {
  group('[http] DatabaseEventStream', () {
    final mockEventSource = MockEventSource();

    setUp(() {
      reset(mockEventSource);
    });

    test('x', () {
      fail('x');
    });
  });
}
