import 'dart:async';

import 'package:dart_test_tools/test.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/src/firebase_database_adapter.dart';
import 'package:flutter_data_firebase_database/src/stream/database_event.dart';
import 'package:flutter_data_firebase_database/src/stream/errors/authentication_revoked.dart';
import 'package:flutter_data_firebase_database/src/stream/errors/remote_cancellation.dart';
import 'package:flutter_data_firebase_database/src/stream/stream_one_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

abstract class UnsupportedEventCb {
  void call(String event, String? path);
}

// TODO use one for all
class TestDataModel extends DataModel<TestDataModel> {
  @override
  final String? id;
  final int? data;

  TestDataModel({
    this.id,
    this.data,
  });

  @override
  bool operator ==(Object other) {
    if (other is! TestDataModel) {
      return false;
    }

    return id == other.id && data == other.data;
  }

  @override
  int get hashCode => id.hashCode ^ data.hashCode;

  @override
  String toString() => 'TestDataModel($id, $data)';
}

class MockUnsupportedEventCb extends Mock implements UnsupportedEventCb {}

class MockFirebaseDatabaseAdapter extends Mock
    implements FirebaseDatabaseAdapter<TestDataModel> {}

void main() {
  group('StreamOneController', () {
    const testId = 'test-id';

    final mockAdapter = MockFirebaseDatabaseAdapter();
    final mockOnUnsupportedEvent = MockUnsupportedEventCb();

    StreamOneController<TestDataModel> createSut(
      Stream<DatabaseEvent> events, {
      bool autoRenew = true,
    }) =>
        StreamOneController(
          id: testId,
          createStream: () async => events,
          adapter: mockAdapter,
          autoRenew: autoRenew,
          onUnsupportedEvent: mockOnUnsupportedEvent,
        );

    setUp(() {
      reset(mockAdapter);
      reset(mockOnUnsupportedEvent);
    });

    group('event', () {
      group('put', () {
        group('with root path', () {
          final resultData = TestDataModel(id: testId, data: 1);

          setUp(() {
            when(() => mockAdapter.deserialize(any()))
                .thenReturn(DeserializedData([resultData]));
          });

          group('and non null data', () {
            test('deserializes event data and emits it', () async {
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

              await expectLater(sut.stream, emits(resultData));

              verify(() => mockAdapter.deserialize(testData));
              verifyNoMoreInteractions(mockAdapter);
            });

            test('uses FirebaseValueTransformer before deserializing',
                () async {
              final stream = Stream.value(
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/',
                    data: {'data': 1},
                  ),
                ),
              );

              final sut = createSut(stream);

              await expectLater(sut.stream, emits(resultData));

              verify(() => mockAdapter.deserialize({'id': testId, 'data': 1}));
              verifyNoMoreInteractions(mockAdapter);
            });

            test('emits new data for every event', () async {
              final stream = Stream.fromIterable(
                const [
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
                ],
              );

              final result1 = resultData;
              final result2 = TestDataModel(id: testId, data: 2);

              when(() => mockAdapter.deserialize(1))
                  .thenReturn(DeserializedData([result1]));
              when(() => mockAdapter.deserialize(2))
                  .thenReturn(DeserializedData([result2]));

              final sut = createSut(stream);

              await expectLater(
                sut.stream,
                emitsInOrder(<dynamic>[result1, result2]),
              );
            });
          });

          group('and null data', () {
            setUp(() {
              when(
                () => mockAdapter.delete(
                  any(),
                  remote: any(named: 'remote'),
                ),
              ).thenReturnAsync(null);
            });

            test('deletes the data from the adapter locally', () async {
              final stream = Stream.value(
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/',
                    data: null,
                  ),
                ),
              );

              final sut = createSut(stream);

              await expectLater(sut.stream, emits(isNull));

              verify(() => mockAdapter.delete(testId, remote: false));
              verifyNoMoreInteractions(mockAdapter);
            });

            test('replaces data in multiple events', () async {
              final stream = Stream.fromIterable(
                const [
                  DatabaseEvent.put(
                    DatabaseEventData(
                      path: '/',
                      data: null,
                    ),
                  ),
                  DatabaseEvent.put(
                    DatabaseEventData(
                      path: '/',
                      data: 1,
                    ),
                  ),
                  DatabaseEvent.put(
                    DatabaseEventData(
                      path: '/',
                      data: null,
                    ),
                  ),
                ],
              );

              final sut = createSut(stream);

              await expectLater(
                sut.stream,
                emitsInOrder(<dynamic>[isNull, resultData, isNull]),
              );
            });
          });
        });

        test('with invalid path forwards event to onUnsupportedEvent callback',
            () async {
          const path = '/a';
          final stream = Stream.value(
            const DatabaseEvent.put(
              DatabaseEventData(
                path: path,
                data: 42,
              ),
            ),
          );

          final sut = createSut(stream);

          await expectLater(sut.stream, neverEmits(anything));

          verifyZeroInteractions(mockAdapter);

          verify(() => mockOnUnsupportedEvent.call('put', path));
        });
      });

      test('patch forwards event to onUnsupportedEvent callback', () async {
        const path = '/';
        final stream = Stream.value(
          const DatabaseEvent.patch(
            DatabaseEventData(
              path: path,
              data: 42,
            ),
          ),
        );

        final sut = createSut(stream);

        await expectLater(sut.stream, neverEmits(anything));

        verifyZeroInteractions(mockAdapter);

        verify(() => mockOnUnsupportedEvent.call('patch', path));
      });

      test('keep-alive does nothing', () async {
        final stream = Stream.value(const DatabaseEvent.keepAlive());

        final sut = createSut(stream);

        await expectLater(sut.stream, neverEmits(anything));

        verifyZeroInteractions(mockAdapter);
        verifyZeroInteractions(mockOnUnsupportedEvent);
      });

      test('cancel adds error to stream', () async {
        const errorMessage = 'error message';
        final stream = Stream.value(const DatabaseEvent.cancel(errorMessage));

        final sut = createSut(stream);

        await expectLater(
          sut.stream,
          emitsError(
            isA<RemoteCancellation>().having(
              (e) => e.reason,
              'reason',
              errorMessage,
            ),
          ),
        );

        verifyZeroInteractions(mockAdapter);
        verifyZeroInteractions(mockOnUnsupportedEvent);
      });

      group('auth_revoked', () {
        setUp(() {
          when(
            () => mockAdapter.delete(
              any(),
              remote: any(named: 'remote'),
            ),
          ).thenReturnAsync(null);
        });

        test('reconnects to new stream and continues event transmission', () {
          final streams = <Stream<DatabaseEvent>>[
            Stream.fromIterable(const [
              DatabaseEvent.put(DatabaseEventData(path: '/', data: null)),
              DatabaseEvent.authRevoked(),
            ]),
            Stream.value(
              const DatabaseEvent.put(DatabaseEventData(path: '/', data: null)),
            ),
          ];

          final sut = StreamOneController(
            id: testId,
            createStream: () async => streams.removeAt(0),
            adapter: mockAdapter,
            autoRenew: true,
            onUnsupportedEvent: mockOnUnsupportedEvent,
          );

          expect(
            sut.stream,
            emitsInOrder(<dynamic>[
              emits(isNull),
              emits(isNull),
              emitsDone,
            ]),
          );
        });

        test('cancels old subscription', () async {
          var cancelled = false;
          final oldStreamController = StreamController<DatabaseEvent>(
            onCancel: () => cancelled = true,
          );
          addTearDown(oldStreamController.close);

          final newStream = Stream.value(
            const DatabaseEvent.put(DatabaseEventData(path: '/', data: null)),
          );
          final streams = [oldStreamController.stream, newStream];

          final sut = StreamOneController(
            id: testId,
            createStream: () async => streams.removeAt(0),
            adapter: mockAdapter,
            autoRenew: true,
            onUnsupportedEvent: mockOnUnsupportedEvent,
          );

          expect(cancelled, isFalse);

          oldStreamController.add(const DatabaseEvent.authRevoked());
          await expectLater(sut.stream, emits(isNull));

          expect(cancelled, isTrue);
        });

        test('forwards cancellation errors as stream error', () async {
          final oldStreamController = StreamController<DatabaseEvent>(
            onCancel: () => throw Exception('cancellation failure'),
          );
          addTearDown(oldStreamController.close);

          final newStream = Stream.value(
            const DatabaseEvent.put(DatabaseEventData(path: '/', data: null)),
          );
          final streams = [oldStreamController.stream, newStream];

          final sut = StreamOneController(
            id: testId,
            createStream: () async => streams.removeAt(0),
            adapter: mockAdapter,
            autoRenew: true,
            onUnsupportedEvent: mockOnUnsupportedEvent,
          );

          oldStreamController.add(const DatabaseEvent.authRevoked());
          await expectLater(
            sut.stream,
            emitsInAnyOrder(<dynamic>[
              emits(isNull),
              emitsError(isException),
              emitsDone,
            ]),
          );
        });

        test('adds revoked error if autoRenew is false', () async {
          final stream = Stream.value(const DatabaseEvent.authRevoked());

          final sut = createSut(stream, autoRenew: false);

          await expectLater(
            sut.stream,
            emitsError(isA<AuthenticationRevoked>()),
          );

          verifyZeroInteractions(mockAdapter);
          verifyZeroInteractions(mockOnUnsupportedEvent);
        });
      });
    });

    test('forwards error events of original stream', () {
      final error = Exception('error message');
      final stream = Stream<DatabaseEvent>.error(error);

      final sut = createSut(stream);

      expect(sut.stream, emitsError(error));
    });

    test('closes controller stream if original stream is closed', () {
      const stream = Stream<DatabaseEvent>.empty();

      final sut = createSut(stream);

      expect(sut.stream, emitsDone);
    });

    test('forwards cancel to original stream', () async {
      var cancelled = false;
      final testController = StreamController<DatabaseEvent>(
        onCancel: () => cancelled = true,
      );
      addTearDown(testController.close);

      final sut = createSut(testController.stream);
      final sub = sut.stream.listen(null);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(cancelled, isFalse);

      await sub.cancel();

      expect(cancelled, isTrue);
    });
  });
}
