import 'package:bloc_test/bloc_test.dart';
import 'package:dart_test_tools/test.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_sync/src/retry_state_machine.dart';
import 'package:flutter_data_sync/src/sync_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class FakeDataModel extends DataModel<FakeDataModel> {
  @override
  Object? get id => throw UnimplementedError();
}

class FakeOfflineOperation extends Fake
    implements OfflineOperation<FakeDataModel> {}

class MockDelayedStateNotifier<T> extends Mock
    implements DelayedStateNotifier<T> {}

class MockRepository<T extends DataModel<T>> extends Mock
    implements Repository<T> {}

class MockRetryStateMachine extends MockBloc<RetryEvent, RetryState>
    implements RetryStateMachine {}

void main() {
  setUpAll(() {
    registerFallbackValue(Provider((ref) => MockRepository<FakeDataModel>()));
  });

  group('$SyncController', () {
    final mockNotifier = MockDelayedStateNotifier<Set<String>>();
    final mockRepository = MockRepository<FakeDataModel>();
    final mockRepository2 = MockRepository<FakeDataModel>();
    final mockRetryStateMachine = MockRetryStateMachine();

    const testRepositoryName1 = 'test-1';
    const testRepositoryName2 = 'test-2';
    const testRepositoryName3 = 'test-3';
    const testRepositoryName4 = 'test-4';
    final testRepositories = {
      testRepositoryName1: Provider((ref) => mockRepository),
      testRepositoryName2: Provider((ref) => mockRepository),
      testRepositoryName3: Provider((ref) => mockRepository2),
      testRepositoryName4: Provider((ref) => mockRepository),
    };

    late ProviderContainer providerContainer;
    late int rmListenerCnt;
    late SyncController sut;

    setUp(() {
      reset(mockNotifier);
      reset(mockRepository);
      reset(mockRepository2);
      reset(mockRetryStateMachine);

      rmListenerCnt = 0;
      when(() => mockRetryStateMachine.close()).thenReturnAsync(null);
      when(() => mockNotifier.addListener(any())).thenReturn(() {
        rmListenerCnt++;
      });

      providerContainer = ProviderContainer();
      addTearDown(providerContainer.dispose);
      sut = SyncController(
        read: providerContainer.read,
        pendingOfflineTypesNotifier: mockNotifier,
        repositoryProviders: testRepositories,
        retryStateMachine: mockRetryStateMachine,
      );
    });

    test('constructor add listener to pending offline types notifier', () {
      expect(rmListenerCnt, 0);

      verify(() => mockNotifier.addListener(any()));
    });

    test('dispose removes notifier listener and closes state machine', () {
      expect(rmListenerCnt, 0);

      sut.dispose();

      expect(rmListenerCnt, 1);
      verify(() => mockRetryStateMachine.close());
    });

    test('addErrorListener calls stateMachine.addErrorListener', () {
      // ignore: prefer_function_declarations_over_variables
      final errorCb = (Object error, StackTrace stackTrace) {};
      // ignore: prefer_function_declarations_over_variables
      final removeErrorCb = () {};

      when(() => mockRetryStateMachine.addErrorListener(any()))
          .thenReturn(removeErrorCb);

      final removeCb = sut.addErrorListener(errorCb);

      verify(() => mockRetryStateMachine.addErrorListener(errorCb));
      expect(removeCb, removeErrorCb);
    });

    test('get enabled calls stateMachine.enabled', () {
      when(() => mockRetryStateMachine.enabled).thenReturn(true);

      expect(sut.enabled, isTrue);

      verify(() => mockRetryStateMachine.enabled);
    });

    test('set enabled calls stateMachine.enabled', () {
      sut.enabled = false;

      verify(() => mockRetryStateMachine.enabled = false);
    });

    test('updates offline operations on change events', () {
      when(() => mockRepository.offlineOperations).thenAnswer(
        (i) => List.generate(5, (i) => FakeOfflineOperation()).toSet(),
      );
      when(() => mockRepository2.offlineOperations).thenReturn({});

      final listener = verify(() => mockNotifier.addListener(captureAny()))
          .captured
          .single as void Function(Set<String>);

      listener.call({
        testRepositoryName1,
        testRepositoryName2,
        testRepositoryName3,
      });

      verify(
        () => mockRetryStateMachine.updatePendingOfflineOperations(
          any(that: hasLength(10)),
        ),
      );
    });
  });
}
