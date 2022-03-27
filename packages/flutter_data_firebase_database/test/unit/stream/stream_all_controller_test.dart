import 'package:dart_test_tools/test.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/src/firebase_database_adapter.dart';
import 'package:flutter_data_firebase_database/src/stream/database_event.dart';
import 'package:flutter_data_firebase_database/src/stream/stream_all_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

abstract class UnsupportedEventCb {
  void call(String event, String? path);
}

class TestDataModel extends DataModel<TestDataModel> {
  @override
  final String? id;
  final int? data;

  TestDataModel({
    this.id,
    this.data,
  });

  @override
  String toString() => 'TestDataModel($id, $data)';
}

class MockUnsupportedEventCb extends Mock implements UnsupportedEventCb {}

class MockFirebaseDatabaseAdapter extends Mock
    implements FirebaseDatabaseAdapter<TestDataModel> {}

void main() {
  group('StreamAllController', () {
    final mockAdapter = MockFirebaseDatabaseAdapter();
    final mockOnUnsupportedEvent = MockUnsupportedEventCb();

    StreamAllController<TestDataModel> createSut(
      Stream<DatabaseEvent> events, {
      bool syncLocal = false,
      bool autoRenew = true,
    }) =>
        StreamAllController(
          createStream: () async => events,
          adapter: mockAdapter,
          syncLocal: syncLocal,
          autoRenew: autoRenew,
          onUnsupportedEvent: mockOnUnsupportedEvent,
        );

    setUp(() {
      reset(mockAdapter);
      reset(mockOnUnsupportedEvent);
    });

    group('put with root path', () {
      final adapterResult = [
        TestDataModel(id: 'a', data: 1),
        TestDataModel(id: 'b', data: 2),
      ];

      setUp(() {
        when(() => mockAdapter.clear()).thenReturnAsync(null);
        when(() => mockAdapter.deserialize(any()))
            .thenReturn(DeserializedData(adapterResult));
      });

      test('deserializes event data and returns full state', () async {
        const testData = 'TEST_DATA';
        final stream = Stream.value(
          const DatabaseEvent.put(
            DatabaseEventData(
              path: '/',
              data: testData,
            ),
          ),
        );

        final sut = createSut(stream);

        await expectLater(sut.stream, emits(adapterResult));

        verify(() => mockAdapter.deserialize(testData));
        verifyNoMoreInteractions(mockAdapter);
      });

      test('clears local state if syncLocal is true', () async {
        const testData = 'TEST_DATA';
        final stream = Stream.value(
          const DatabaseEvent.put(
            DatabaseEventData(
              path: '/',
              data: testData,
            ),
          ),
        );

        final sut = createSut(stream, syncLocal: true);

        await expectLater(sut.stream, emits(adapterResult));

        verifyInOrder([
          () => mockAdapter.clear(),
          () => mockAdapter.deserialize(testData),
        ]);
        verifyNoMoreInteractions(mockAdapter);
      });

      test('uses FirebaseValueTransformer before deserializing', () async {
        final stream = Stream.value(
          const DatabaseEvent.put(
            DatabaseEventData(
              path: '/',
              data: {
                'a': {'data': 1},
                'b': {'data': 2},
              },
            ),
          ),
        );

        final sut = createSut(stream);

        await expectLater(sut.stream, emits(adapterResult));

        verify(
          () => mockAdapter.deserialize([
            {'id': 'a', 'data': 1},
            {'id': 'b', 'data': 2},
          ]),
        );
        verifyNoMoreInteractions(mockAdapter);
      });

      test('replaces previous state', () async {
        final stream = Stream.fromIterable(const [
          DatabaseEvent.put(
            DatabaseEventData(
              path: '/',
              data: 1,
            ),
          ),
          DatabaseEvent.put(
            DatabaseEventData(
              path: '/',
              data: 2,
            ),
          ),
        ]);

        final replaceResult = [
          TestDataModel(id: 'a', data: 3),
          TestDataModel(id: 'c', data: 4),
        ];

        when(() => mockAdapter.deserialize(1))
            .thenReturn(DeserializedData(adapterResult));
        when(() => mockAdapter.deserialize(2))
            .thenReturn(DeserializedData(replaceResult));

        final sut = createSut(stream);

        await expectLater(
          sut.stream,
          emitsInOrder(<dynamic>[
            adapterResult,
            replaceResult,
          ]),
        );
      });
    });

    group('put with sub path', () {
      group('and non null data', () {
        final adapterResult = [
          TestDataModel(id: 'a', data: 1),
        ];

        setUp(() {
          when(() => mockAdapter.deserialize(any()))
              .thenReturn(DeserializedData(adapterResult));
        });

        test('deserializes event data and state with new data', () async {
          const testData = 'TEST_DATA';
          final stream = Stream.value(
            const DatabaseEvent.put(
              DatabaseEventData(
                path: '/a',
                data: testData,
              ),
            ),
          );

          final sut = createSut(stream);

          await expectLater(sut.stream, emits(adapterResult));

          verify(() => mockAdapter.deserialize(testData));
          verifyNoMoreInteractions(mockAdapter);
        });

        test('uses FirebaseValueTransformer before deserializing', () async {
          final stream = Stream.value(
            const DatabaseEvent.put(
              DatabaseEventData(
                path: '/a',
                data: {'data': 1},
              ),
            ),
          );

          final sut = createSut(stream);

          await expectLater(sut.stream, emits(adapterResult));

          verify(() => mockAdapter.deserialize({'id': 'a', 'data': 1}));
          verifyNoMoreInteractions(mockAdapter);
        });

        test('adds or replaces element in previous state', () async {
          final stream = Stream.fromIterable(
            const [
              DatabaseEvent.put(
                DatabaseEventData(
                  path: '/a',
                  data: 1,
                ),
              ),
              DatabaseEvent.put(
                DatabaseEventData(
                  path: '/b',
                  data: 2,
                ),
              ),
              DatabaseEvent.put(
                DatabaseEventData(
                  path: '/c',
                  data: 3,
                ),
              ),
              DatabaseEvent.put(
                DatabaseEventData(
                  path: '/b',
                  data: 4,
                ),
              ),
            ],
          );

          final result1 = adapterResult;
          final result2 = [TestDataModel(id: 'b', data: 2)];
          final result3 = [TestDataModel(id: 'c', data: 3)];
          final result4 = [TestDataModel(id: 'b', data: 4)];

          when(() => mockAdapter.deserialize(1))
              .thenReturn(DeserializedData(result1));
          when(() => mockAdapter.deserialize(2))
              .thenReturn(DeserializedData(result2));
          when(() => mockAdapter.deserialize(3))
              .thenReturn(DeserializedData(result3));
          when(() => mockAdapter.deserialize(4))
              .thenReturn(DeserializedData(result4));

          final sut = createSut(stream);

          await expectLater(
            sut.stream,
            emitsInOrder(<dynamic>[
              result1,
              [...result1, ...result2],
              [...result1, ...result2, ...result3],
              [...result1, ...result4, ...result3],
            ]),
          );
        });
      });
    });
  });
}
