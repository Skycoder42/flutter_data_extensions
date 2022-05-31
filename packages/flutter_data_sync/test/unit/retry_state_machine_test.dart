import 'dart:async';
import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:dart_test_tools/test.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_sync/src/retry_state_machine.dart';
import 'package:flutter_data_sync/src/semaphore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class FakeDataModel extends Fake implements DataModel<FakeDataModel> {}

class MockOfflineOperation extends Mock
    implements
        // ignore: avoid_implementing_value_types
        OfflineOperation<FakeDataModel> {
  bool allowEqual = true;

  @override
  int get hashCode =>
      allowEqual ? super.hashCode : Random.secure().nextInt(1 << 31);

  @override
  // ignore: avoid_bool_literals_in_conditional_expressions
  bool operator ==(Object other) => allowEqual ? super == other : false;
}

class TestableRetryStateMachine extends RetryStateMachine {
  final bool disableClose;

  TestableRetryStateMachine({this.disableClose = true});

  @override
  // ignore: must_call_super
  Future<void> close() => disableClose ? Future.value() : super.close();

  Future<void> forceClose() => super.close();
}

void main() {
  Matcher isDisposed() => predicate<RetryState>(
        (state) => state.maybeMap(
          disposed: (_) => true,
          orElse: () => false,
        ),
        'is RetryState.disposed',
      );

  Matcher isDisposing() => predicate<RetryState>(
        (state) => state.maybeMap(
          disposing: (_) => true,
          orElse: () => false,
        ),
        'is RetryState.disposing',
      );

  RetryStateMachine createStateMachine({
    bool disableClose = true,
  }) =>
      TestableRetryStateMachine(
        disableClose: disableClose,
      )..addErrorListener((error, stackTrace) => fail(error.toString()));

  group('$RetryStateMachine', () {
    final mockOperation = MockOfflineOperation();

    setUp(() {
      reset(mockOperation);
      mockOperation.allowEqual = true;
    });

    test('initial state is idle state', () {
      final sut = createStateMachine();
      expect(sut.state, const RetryState.idle());
      expect(sut.enabled, isTrue);
    });

    group('idle', () {
      const seedState = RetryState.idle();

      blocTest<RetryStateMachine, RetryState>(
        '-{enable}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = true,
        expect: () => <dynamic>[],
        verify: (bloc) {
          expect(bloc.enabled, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{disable}-> [disabled]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = false,
        expect: () => [
          const RetryState.disabled(),
        ],
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{updatePendingOfflineOperations}-> [pendingRetry(retryCount: 0)]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.updatePendingOfflineOperations({mockOperation}),
        expect: () => [
          const RetryState.pendingRetry(),
        ],
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{close}-> [disposed]',
        build: () => createStateMachine(disableClose: false),
        seed: () => seedState,
        expect: () => [
          isDisposed(),
        ],
        verify: (bloc) {
          expect(bloc.isClosed, isTrue);
        },
      );
    });

    group('disabled', () {
      const seedState = RetryState.disabled();

      blocTest<RetryStateMachine, RetryState>(
        '-{enable [no pending operations]}-> [idle]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = true,
        expect: () => [
          const RetryState.idle(),
        ],
        verify: (bloc) {
          expect(bloc.enabled, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{enable [pending operations]}-> [pendingRetry(retryCount: 0)]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc
          ..debugSetPendingOfflineOperations({mockOperation})
          ..enabled = true,
        expect: () => [
          const RetryState.pendingRetry(),
        ],
        verify: (bloc) {
          expect(bloc.enabled, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{disable}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = false,
        expect: () => <dynamic>[],
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{updatePendingOfflineOperations}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.updatePendingOfflineOperations({mockOperation}),
        expect: () => <dynamic>[],
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{close}-> [disposed]',
        build: () => createStateMachine(disableClose: false),
        seed: () => seedState,
        expect: () => [
          isDisposed(),
        ],
        verify: (bloc) {
          expect(bloc.isClosed, isTrue);
        },
      );
    });

    group('pendingRetry(retryCount: 1)', () {
      const seedState = RetryState.pendingRetry(
        retryCount: 1,
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{enable}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = true,
        expect: () => <dynamic>[],
        verify: (bloc) {
          expect(bloc.enabled, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{disable}-> [disabled]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = false,
        expect: () => [
          const RetryState.disabled(),
        ],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{updatePendingOfflineOperations}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.updatePendingOfflineOperations({mockOperation}),
        expect: () => <dynamic>[],
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{close}-> [disposed]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => (bloc as TestableRetryStateMachine).forceClose(),
        expect: () => [
          isDisposed(),
        ],
        wait: const Duration(seconds: 2),
        verify: (bloc) {
          expect(bloc.isClosed, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{<timeout> [no pending operations]}-> [idle]',
        build: createStateMachine,
        seed: () => seedState,
        wait: const Duration(seconds: 2),
        expect: () => [
          const RetryState.idle(),
        ],
      );

      blocTest<RetryStateMachine, RetryState>(
        // ignore: lines_longer_than_80_chars
        '-{<timeout> [pending operations]}-> [retrying(retryCount: 1, offlineOperations: {...})]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.debugSetPendingOfflineOperations({mockOperation}),
        wait: const Duration(seconds: 2),
        expect: () => [
          RetryState.retrying(
            retryCount: 1,
            offlineOperations: {mockOperation},
          ),
        ],
      );
    });

    group('retrying(retryCount: 5, offlineOperations: {...})', () {
      const retryCount = 5;
      final seedState = RetryState.retrying(
        retryCount: retryCount,
        offlineOperations: {mockOperation},
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{enable}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = true,
        expect: () => <dynamic>[],
        verify: (bloc) {
          expect(bloc.enabled, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{disable}-> [cancellingDisabled]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = false,
        expect: () => [
          const RetryState.cancellingDisabled(),
        ],
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{updatePendingOfflineOperations}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.updatePendingOfflineOperations({mockOperation}),
        expect: () => <dynamic>[],
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{close}-> [disposing]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) {
          (bloc as TestableRetryStateMachine).forceClose();
        },
        expect: () => [
          isDisposing(),
        ],
        verify: (bloc) {
          expect(bloc.isClosed, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{processOperations}-> [pendingRetry(retryCount: 6)]',
        build: createStateMachine,
        setUp: () {
          when(() => mockOperation.retry<dynamic>()).thenReturnAsync(null);
        },
        seed: () => seedState,
        expect: () => [
          const RetryState.pendingRetry(retryCount: retryCount + 1),
        ],
        verify: (bloc) {
          verify(() => mockOperation.retry<dynamic>()).called(1);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{processOperations [x operations]}-> [pendingRetry(retryCount: 6)]',
        build: createStateMachine,
        setUp: () {
          mockOperation.allowEqual = false;
          when(() => mockOperation.retry<dynamic>()).thenReturnAsync(null);
        },
        seed: () => RetryState.retrying(
          retryCount: retryCount,
          offlineOperations:
              List.filled(Semaphore.defaultMaxCount * 2, mockOperation).toSet(),
        ),
        wait: const Duration(seconds: 2),
        expect: () => [
          const RetryState.pendingRetry(retryCount: retryCount + 1),
        ],
        verify: (bloc) {
          verify(() => mockOperation.retry<dynamic>())
              .called(Semaphore.defaultMaxCount * 2);
        },
      );
    });

    group('cancellingDisabled', () {
      const seedState = RetryState.cancellingDisabled();

      blocTest<RetryStateMachine, RetryState>(
        '-{enable}-> [cancellingEnabled]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = true,
        expect: () => [
          const RetryState.cancellingEnabled(),
        ],
        verify: (bloc) {
          expect(bloc.enabled, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{disable}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = false,
        expect: () => <dynamic>[],
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{updatePendingOfflineOperations}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.updatePendingOfflineOperations({mockOperation}),
        expect: () => <dynamic>[],
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{close}-> [disposing]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) {
          (bloc as TestableRetryStateMachine).forceClose();
        },
        expect: () => [
          isDisposing(),
        ],
        verify: (bloc) {
          expect(bloc.isClosed, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{processingDone}-> [disabled]',
        build: createStateMachine,
        setUp: () {
          mockOperation.allowEqual = false;
          when(() => mockOperation.retry<dynamic>()).thenReturnAsync(
            Future.delayed(const Duration(milliseconds: 250)),
          );
        },
        seed: () => RetryState.retrying(
          retryCount: 0,
          offlineOperations: List.filled(2, mockOperation).toSet(),
        ),
        act: (bloc) => bloc.enabled = false,
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const RetryState.cancellingDisabled(),
          const RetryState.disabled(),
        ],
        verify: (bloc) {
          verify(() => mockOperation.retry<dynamic>()).called(1);
        },
      );
    });

    group('cancellingEnabled', () {
      const seedState = RetryState.cancellingEnabled();

      blocTest<RetryStateMachine, RetryState>(
        '-{enable}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = true,
        expect: () => isEmpty,
        verify: (bloc) {
          expect(bloc.enabled, isTrue);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{disable}-> [cancellingDisabled]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.enabled = false,
        expect: () => const [
          RetryState.cancellingDisabled(),
        ],
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{updatePendingOfflineOperations}-> []',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) => bloc.updatePendingOfflineOperations({mockOperation}),
        expect: () => <dynamic>[],
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{close}-> [disposing]',
        build: createStateMachine,
        seed: () => seedState,
        act: (bloc) {
          (bloc as TestableRetryStateMachine).forceClose();
        },
        expect: () => [
          isDisposing(),
        ],
        verify: (bloc) {
          expect(bloc.isClosed, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{processingDone [no pending operations]}-> [idle]',
        build: createStateMachine,
        setUp: () {
          mockOperation.allowEqual = false;
          when(() => mockOperation.retry<dynamic>()).thenReturnAsync(
            Future.delayed(const Duration(milliseconds: 250)),
          );
        },
        seed: () => RetryState.retrying(
          retryCount: 0,
          offlineOperations: {mockOperation, mockOperation},
        ),
        act: (bloc) => bloc
          ..enabled = false
          ..enabled = true,
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const RetryState.cancellingDisabled(),
          const RetryState.cancellingEnabled(),
          const RetryState.idle(),
        ],
        verify: (bloc) {
          verify(() => mockOperation.retry<dynamic>()).called(1);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{processingDone [pending operations]}-> [pendingRetry]',
        build: createStateMachine,
        setUp: () {
          mockOperation.allowEqual = false;
          when(() => mockOperation.retry<dynamic>()).thenReturnAsync(
            Future.delayed(const Duration(milliseconds: 250)),
          );
        },
        seed: () => RetryState.retrying(
          retryCount: 0,
          offlineOperations: {mockOperation, mockOperation},
        ),
        act: (bloc) => bloc
          ..enabled = false
          ..updatePendingOfflineOperations({mockOperation})
          ..enabled = true,
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const RetryState.cancellingDisabled(),
          const RetryState.cancellingEnabled(),
          const RetryState.pendingRetry(),
        ],
        verify: (bloc) {
          verify(() => mockOperation.retry<dynamic>()).called(1);
        },
      );
    });

    group('disposing', () {
      RetryState createSeedState() => RetryState.disposing(
            closeCompleter: Completer(),
          );

      blocTest<RetryStateMachine, RetryState>(
        '-{enable}-> []',
        build: createStateMachine,
        seed: createSeedState,
        act: (bloc) => bloc.enabled = true,
        expect: () => isEmpty,
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{disable}-> []',
        build: createStateMachine,
        seed: createSeedState,
        act: (bloc) => bloc.enabled = false,
        expect: () => isEmpty,
        verify: (bloc) {
          expect(bloc.enabled, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{updatePendingOfflineOperations}-> []',
        build: createStateMachine,
        seed: createSeedState,
        act: (bloc) => bloc.updatePendingOfflineOperations({mockOperation}),
        expect: () => isEmpty,
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{close}-> []',
        build: createStateMachine,
        seed: createSeedState,
        act: (bloc) {
          (bloc as TestableRetryStateMachine).forceClose();
        },
        expect: () => isEmpty,
        verify: (bloc) {
          expect(bloc.isClosed, isFalse);
        },
      );

      blocTest<RetryStateMachine, RetryState>(
        '-{processingDone}-> [disposed]',
        build: createStateMachine,
        setUp: () {
          mockOperation.allowEqual = false;
          when(() => mockOperation.retry<dynamic>()).thenReturnAsync(
            Future.delayed(const Duration(milliseconds: 250)),
          );
        },
        seed: () => RetryState.retrying(
          retryCount: 0,
          offlineOperations: {mockOperation, mockOperation},
        ),
        act: (bloc) {
          (bloc as TestableRetryStateMachine).forceClose();
        },
        wait: const Duration(milliseconds: 500),
        expect: () => [
          isDisposing(),
          isDisposed(),
        ],
        verify: (bloc) {
          verify(() => mockOperation.retry<dynamic>());
          expect(bloc.isClosed, isTrue);
        },
      );
    });

    test('disposed auto closes bloc', () async {
      final completer = Completer<void>();
      final sut = createStateMachine(disableClose: false);
      expect(sut.isClosed, isFalse);

      sut.emit(
        RetryState.disposed(
          closeCompleter: completer,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(sut.isClosed, isTrue);
      expect(sut.state, isDisposed());
    });

    test(
      'close transitions to disposed via disposing and closes with bloc',
      () async {
        final sut = createStateMachine(disableClose: false);

        expect(
          sut.stream,
          emitsInOrder(<dynamic>[
            const RetryState.cancellingDisabled(),
            isDisposing(),
            isDisposed(),
            emitsDone,
          ]),
        );

        sut.emit(const RetryState.cancellingDisabled());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(sut.close(), completes);

        expect(sut.isClosed, isFalse);
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // ignore: invalid_use_of_protected_member
        sut.add(const RetryEvent.processingDone());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(sut.isClosed, isTrue);
      },
    );

    test('addErrorListener listens for errors', () async {
      var errorCnt = 0;
      final sut = TestableRetryStateMachine(
        disableClose: false,
      );
      final handle = sut.addErrorListener((error, stackTrace) {
        errorCnt++;
      });

      // ignore: invalid_use_of_protected_member
      sut.addError(Exception(), StackTrace.empty);
      expect(errorCnt, 1);

      handle();

      // ignore: invalid_use_of_protected_member
      sut.addError(Exception(), StackTrace.empty);
      expect(errorCnt, 1);
    });
  });
}
