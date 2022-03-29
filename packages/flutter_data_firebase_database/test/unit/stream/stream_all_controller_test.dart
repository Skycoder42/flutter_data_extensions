import 'dart:async';

import 'package:dart_test_tools/test.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/src/firebase_database_adapter.dart';
import 'package:flutter_data_firebase_database/src/stream/database_event.dart';
import 'package:flutter_data_firebase_database/src/stream/errors/authentication_revoked.dart';
import 'package:flutter_data_firebase_database/src/stream/errors/remote_cancellation.dart';
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

  @override
  bool operator ==(Object other) {
    if (other is! TestDataModel) {
      return false;
    }

    return id == other.id && data == other.data;
  }

  @override
  int get hashCode => id.hashCode ^ data.hashCode;
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

    group('event', () {
      group('put', () {
        group('with root path', () {
          group('and non null data', () {
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

            test('returns an unmodifiable state', () async {
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

              final data = await sut.stream.first;

              expect(data, hasLength(2));
              expect(() => data.removeAt(0), throwsUnsupportedError);
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

            test('uses FirebaseValueTransformer before deserializing',
                () async {
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

          group('and null data', () {
            setUp(() {
              when(() => mockAdapter.clear()).thenReturnAsync(null);
            });

            test('does nothing by default', () async {
              final stream = Stream.value(
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/',
                    data: null,
                  ),
                ),
              );

              final sut = createSut(stream);

              await expectLater(sut.stream, emits(isEmpty));

              verifyZeroInteractions(mockAdapter);
            });

            test('returns an unmodifiable state', () async {
              final stream = Stream.value(
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/',
                    data: null,
                  ),
                ),
              );

              final sut = createSut(stream);

              final data = await sut.stream.first;

              expect(data, isEmpty);
              expect(() => data.add(TestDataModel()), throwsUnsupportedError);
            });

            test('clears local storage if syncLocal is true', () async {
              final stream = Stream.value(
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/',
                    data: null,
                  ),
                ),
              );

              final sut = createSut(stream, syncLocal: true);

              await expectLater(sut.stream, emits(const <TestDataModel>[]));

              verify(() => mockAdapter.clear());
              verifyNoMoreInteractions(mockAdapter);
            });

            test('replaces internal state with empty array', () async {
              final stream = Stream.fromIterable([
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/',
                    data: 1,
                  ),
                ),
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/',
                    data: null,
                  ),
                ),
              ]);

              final initialData = [
                TestDataModel(id: 'a', data: 1),
                TestDataModel(id: 'b', data: 2),
              ];
              when(() => mockAdapter.deserialize(1)).thenReturn(
                DeserializedData(initialData),
              );

              final sut = createSut(stream);

              await expectLater(
                sut.stream,
                emitsInOrder(<dynamic>[
                  initialData,
                  isEmpty,
                ]),
              );
            });
          });
        });

        group('with sub path', () {
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

            test('returns an unmodifiable state', () async {
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

              final data = await sut.stream.first;

              expect(data, hasLength(1));
              expect(() => data.removeAt(0), throwsUnsupportedError);
            });

            test('uses FirebaseValueTransformer before deserializing',
                () async {
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

              final result1 = adapterResult.single;
              final result2 = TestDataModel(id: 'b', data: 2);
              final result3 = TestDataModel(id: 'c', data: 3);
              final result4 = TestDataModel(id: 'b', data: 4);

              when(() => mockAdapter.deserialize(1))
                  .thenReturn(DeserializedData([result1]));
              when(() => mockAdapter.deserialize(2))
                  .thenReturn(DeserializedData([result2]));
              when(() => mockAdapter.deserialize(3))
                  .thenReturn(DeserializedData([result3]));
              when(() => mockAdapter.deserialize(4))
                  .thenReturn(DeserializedData([result4]));

              final sut = createSut(stream);

              await expectLater(
                sut.stream,
                emitsInOrder(<dynamic>[
                  [result1],
                  [result1, result2],
                  [result1, result2, result3],
                  [result1, result4, result3],
                ]),
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
                    path: '/a',
                    data: null,
                  ),
                ),
              );

              final sut = createSut(stream);

              await expectLater(sut.stream, emits(isEmpty));

              verify(() => mockAdapter.delete('a', remote: false));
              verifyNoMoreInteractions(mockAdapter);
            });

            test('returns an unmodifiable state', () async {
              final stream = Stream.value(
                const DatabaseEvent.put(
                  DatabaseEventData(
                    path: '/a',
                    data: null,
                  ),
                ),
              );

              final sut = createSut(stream);

              final data = await sut.stream.first;

              expect(data, isEmpty);
              expect(() => data.add(TestDataModel()), throwsUnsupportedError);
            });

            test('removes elements from previous state', () async {
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
                      path: '/a',
                      data: null,
                    ),
                  ),
                ],
              );

              final result1 = TestDataModel(id: 'a', data: 1);
              final result2 = TestDataModel(id: 'b', data: 2);

              when(() => mockAdapter.deserialize(1))
                  .thenReturn(DeserializedData([result1]));
              when(() => mockAdapter.deserialize(2))
                  .thenReturn(DeserializedData([result2]));

              final sut = createSut(stream);

              await expectLater(
                sut.stream,
                emitsInOrder(<dynamic>[
                  [result1],
                  [result1, result2],
                  [result2],
                ]),
              );
            });
          });
        });

        test('with invalid path forwards event to onUnsupportedEvent callback',
            () async {
          const path = '/a/data';
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

      group('patch', () {
        group('with root path', () {
          final adapterResult = [
            TestDataModel(id: 'a', data: 1),
            TestDataModel(id: 'b', data: 2),
          ];

          setUp(() {
            when(() => mockAdapter.clear()).thenReturnAsync(null);
            when(() => mockAdapter.deserialize(any()))
                .thenReturn(DeserializedData(adapterResult));
            when(
              () => mockAdapter.delete(
                any(),
                remote: any(named: 'remote'),
              ),
            ).thenReturnAsync(null);
          });

          test('adds non null entries to the state', () async {
            const testData = {
              'a': {'data': 1},
              'b': {'data': 2},
            };
            final stream = Stream.value(
              const DatabaseEvent.patch(
                DatabaseEventData(
                  path: '/',
                  data: testData,
                ),
              ),
            );

            final sut = createSut(stream);

            await expectLater(sut.stream, emits(adapterResult));

            verify(
              () => mockAdapter.deserialize({
                {'id': 'a', 'data': 1},
                {'id': 'b', 'data': 2},
              }),
            );
            verifyNoMoreInteractions(mockAdapter);
          });

          test('removes null entries from storage', () async {
            final stream = Stream.value(
              const DatabaseEvent.patch(
                DatabaseEventData(
                  path: '/',
                  data: {'a': null, 'b': null},
                ),
              ),
            );

            when(() => mockAdapter.deserialize(any()))
                .thenReturn(const DeserializedData([]));

            final sut = createSut(stream);

            await expectLater(sut.stream, emits(isEmpty));

            verifyInOrder([
              () => mockAdapter.delete('a', remote: false),
              () => mockAdapter.delete('b', remote: false),
              () => mockAdapter.deserialize(any(that: isEmpty)),
            ]);
            verifyNoMoreInteractions(mockAdapter);
          });

          test('updates, replaces or deletes elements in previous state',
              () async {
            final stream = Stream.fromIterable([
              const DatabaseEvent.patch(
                DatabaseEventData(
                  path: '/',
                  data: {
                    'a': 1,
                    'b': 2,
                    'c': 3,
                  },
                ),
              ),
              const DatabaseEvent.patch(
                DatabaseEventData(
                  path: '/',
                  data: {
                    'd': 4,
                    'a': 5,
                    'c': null,
                  },
                ),
              ),
            ]);

            final state1 = [
              TestDataModel(id: 'a', data: 1),
              TestDataModel(id: 'b', data: 2),
              TestDataModel(id: 'c', data: 3),
            ];
            final state2 = [
              TestDataModel(id: 'a', data: 5),
              TestDataModel(id: 'b', data: 2),
              TestDataModel(id: 'd', data: 4),
            ];

            when(() => mockAdapter.deserialize([1, 2, 3]))
                .thenReturn(DeserializedData(state1));
            when(() => mockAdapter.deserialize([4, 5]))
                .thenReturn(DeserializedData([state2[2], state2[0]]));

            final sut = createSut(stream);

            await expectLater(
              sut.stream,
              emitsInOrder(<dynamic>[
                state1,
                state2,
              ]),
            );

            verifyInOrder([
              () => mockAdapter.deserialize([1, 2, 3]),
              () => mockAdapter.delete('c', remote: false),
              () => mockAdapter.deserialize([4, 5]),
            ]);
          });
        });

        test(
          'with non root path forwards event to onUnsupportedEvent callback',
          () async {
            const path = '/a';
            final stream = Stream.value(
              const DatabaseEvent.patch(
                DatabaseEventData(
                  path: path,
                  data: {'data': 42},
                ),
              ),
            );

            final sut = createSut(stream);

            await expectLater(sut.stream, neverEmits(anything));

            verifyZeroInteractions(mockAdapter);

            verify(() => mockOnUnsupportedEvent.call('patch', path));
          },
        );
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

          final sut = StreamAllController(
            createStream: () async => streams.removeAt(0),
            adapter: mockAdapter,
            syncLocal: false,
            autoRenew: true,
            onUnsupportedEvent: mockOnUnsupportedEvent,
          );

          expect(
            sut.stream,
            emitsInOrder(<dynamic>[
              emits(isEmpty),
              emits(isEmpty),
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

          final sut = StreamAllController(
            createStream: () async => streams.removeAt(0),
            adapter: mockAdapter,
            syncLocal: false,
            autoRenew: true,
            onUnsupportedEvent: mockOnUnsupportedEvent,
          );

          expect(cancelled, isFalse);

          oldStreamController.add(const DatabaseEvent.authRevoked());
          await expectLater(sut.stream, emits(isEmpty));

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

          final sut = StreamAllController(
            createStream: () async => streams.removeAt(0),
            adapter: mockAdapter,
            syncLocal: false,
            autoRenew: true,
            onUnsupportedEvent: mockOnUnsupportedEvent,
          );

          oldStreamController.add(const DatabaseEvent.authRevoked());
          await expectLater(
            sut.stream,
            emitsInAnyOrder(<dynamic>[
              emits(isEmpty),
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

    test('forwards pause, resume and cancel to original stream', () async {
      var paused = false;
      var resumed = false;
      var cancelled = false;
      final testController = StreamController<DatabaseEvent>(
        onPause: () => paused = true,
        onResume: () => resumed = true,
        onCancel: () => cancelled = true,
      );

      final sut = createSut(testController.stream);
      final sub = sut.stream.listen(null);
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(paused, isFalse);
      expect(resumed, isFalse);
      expect(cancelled, isFalse);

      sub.pause();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(paused, isTrue);
      expect(resumed, isFalse);
      expect(cancelled, isFalse);

      sub.resume();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(paused, isTrue);
      expect(resumed, isTrue);
      expect(cancelled, isFalse);

      await sub.cancel();

      expect(paused, isTrue);
      expect(resumed, isTrue);
      expect(cancelled, isTrue);

      await testController.close();
    });
  });
}
