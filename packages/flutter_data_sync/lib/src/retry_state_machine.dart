import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:state_machine_bloc/state_machine_bloc.dart';

import 'semaphore.dart';

part 'retry_state_machine.freezed.dart';

typedef OnErrorCb = void Function(Object error, StackTrace stackTrace);
typedef RemoveErrorListenerCb = void Function();

late final retryStateMachineProvider = Provider(
  (ref) => RetryStateMachine(),
);

@freezed
class RetryState with _$RetryState {
  const factory RetryState.idle() = _IdleState;
  const factory RetryState.disabled() = _DisabledState;
  const factory RetryState.pendingRetry({
    @Default(0) int retryCount,
  }) = _PendingRetryState;
  const factory RetryState.retrying({
    required int retryCount,
    required Set<OfflineOperation> offlineOperations,
  }) = _RetryingState;
  const factory RetryState.cancellingDisabled() = _CancellingDisabledState;
  const factory RetryState.cancellingEnabled() = _CancellingEnabledState;
  const factory RetryState.disposing({
    required Completer<void> closeCompleter,
  }) = _DisposingState;
  const factory RetryState.disposed({
    required Completer<void> closeCompleter,
  }) = _DisposedState;
}

@freezed
class RetryEvent with _$RetryEvent {
  const factory RetryEvent.enable() = _EnableEvent;
  const factory RetryEvent.disable() = _DisableEvent;
  const factory RetryEvent.retryOperations() = _RetryOperationsEvent;
  const factory RetryEvent.process() = _ProcessEvent;
  const factory RetryEvent.processingDone() = _ProcessingDoneEvent;
  const factory RetryEvent.dispose(Completer<void> closeCompleter) =
      _DisposeEvent;
}

class RetryStateMachine extends StateMachine<RetryEvent, RetryState> {
  final _errorListeners = <OnErrorCb>[];

  var _pendingOfflineOperations = const <OfflineOperation>{};
  Timer? _retryTimer;

  RetryStateMachine()
      : super(
          const RetryState.idle(),
          transformer: sequential(),
        ) {
    define<_IdleState>(
      (s) => s
        ..on<_DisableEvent>((e, s) => const RetryState.disabled())
        ..on<_RetryOperationsEvent>(
          (e, s) => const RetryState.pendingRetry(),
        )
        ..on<_DisposeEvent>(
          (e, s) => RetryState.disposed(
            closeCompleter: e.closeCompleter,
          ),
        ),
    );

    define<_DisabledState>(
      (s) => s
        ..on<_EnableEvent>(
          (e, s) => _pendingOfflineOperations.isEmpty
              ? const RetryState.idle()
              : const RetryState.pendingRetry(),
        )
        ..on<_DisposeEvent>(
          (e, s) => RetryState.disposed(
            closeCompleter: e.closeCompleter,
          ),
        ),
    );

    define<_PendingRetryState>(
      (s) => s
        ..onEnter((s) {
          _retryTimer = Timer(
            _calculateRetryDelay(s.retryCount),
            () => add(const RetryEvent.process()),
          );
        })
        ..onExit((s) {
          _retryTimer?.cancel();
          _retryTimer = null;
        })
        ..on<_DisableEvent>((e, s) => const RetryState.disabled())
        ..on<_ProcessEvent>(
          (e, s) => _pendingOfflineOperations.isEmpty
              ? const RetryState.idle()
              : RetryState.retrying(
                  retryCount: s.retryCount,
                  offlineOperations: _pendingOfflineOperations,
                ),
        )
        ..on<_DisposeEvent>(
          (e, s) => RetryState.disposed(
            closeCompleter: e.closeCompleter,
          ),
        ),
    );

    define<_RetryingState>(
      (s) => s
        ..onEnter((s) => _processOperations(s.offlineOperations))
        ..on<_DisableEvent>(
          (e, s) => const RetryState.cancellingDisabled(),
        )
        ..on<_ProcessingDoneEvent>(
          (e, s) => RetryState.pendingRetry(
            retryCount: s.retryCount + 1, // TODO decrement if less operations
          ),
        )
        ..on<_DisposeEvent>(
          (e, s) => RetryState.disposing(
            closeCompleter: e.closeCompleter,
          ),
        ),
    );

    define<_CancellingDisabledState>(
      (s) => s
        ..on<_EnableEvent>(
          (e, s) => const RetryState.cancellingEnabled(),
        )
        ..on<_ProcessingDoneEvent>(
          (e, s) => const RetryState.disabled(),
        )
        ..on<_DisposeEvent>(
          (e, s) => RetryState.disposing(
            closeCompleter: e.closeCompleter,
          ),
        ),
    );

    define<_CancellingEnabledState>(
      (s) => s
        ..on<_DisableEvent>(
          (e, s) => const RetryState.cancellingDisabled(),
        )
        ..on<_ProcessingDoneEvent>(
          (e, s) => _pendingOfflineOperations.isEmpty
              ? const RetryState.idle()
              : const RetryState.pendingRetry(),
        )
        ..on<_DisposeEvent>(
          (e, s) => RetryState.disposing(
            closeCompleter: e.closeCompleter,
          ),
        ),
    );

    define<_DisposingState>(
      (s) => s
        ..on<_ProcessingDoneEvent>(
          (e, s) => RetryState.disposed(
            closeCompleter: s.closeCompleter,
          ),
        ),
    );

    define<_DisposedState>(
      (s) => s
        ..onEnter((s) async {
          assert(!s.closeCompleter.isCompleted);
          s.closeCompleter.complete(super.close());
        }),
    );
  }

  RemoveErrorListenerCb addErrorListener(OnErrorCb onError) {
    assert(!_errorListeners.contains(onError));
    _errorListeners.add(onError);
    return () => _errorListeners.remove(onError);
  }

  bool get enabled => state.map(
        disabled: (_) => false,
        cancellingDisabled: (_) => false,
        disposing: (_) => false,
        disposed: (_) => false,
        idle: (_) => true,
        pendingRetry: (_) => true,
        retrying: (_) => true,
        cancellingEnabled: (_) => true,
      );

  set enabled(bool enabled) =>
      add(enabled ? const RetryEvent.enable() : const RetryEvent.disable());

  void updatePendingOfflineOperations(Set<OfflineOperation> offlineOperations) {
    _pendingOfflineOperations = offlineOperations;
    add(const RetryEvent.retryOperations());
  }

  @override
  @protected
  void add(RetryEvent event) {
    super.add(event);
  }

  @override
  @protected
  void onError(Object error, StackTrace stackTrace) {
    for (final errorListener in _errorListeners) {
      errorListener(error, stackTrace);
    }
    super.onError(error, stackTrace);
  }

  @override
  // ignore: must_call_super
  Future<void> close() {
    if (isClosed) {
      throw StateError('Cannot close the state machine twice');
    }
    final closeCompleter = Completer<void>();
    add(RetryEvent.dispose(closeCompleter));
    return closeCompleter.future;
  }

  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void debugSetPendingOfflineOperations(
    Set<OfflineOperation> offlineOperations,
  ) {
    _pendingOfflineOperations = offlineOperations;
  }

  Future<void> _processOperations(
    Set<OfflineOperation> offlineOperations,
  ) async {
    assert(offlineOperations.isNotEmpty);

    final semaphore = Semaphore();
    try {
      for (final operation in offlineOperations) {
        await semaphore.acquire();

        final isCancelling = state.maybeMap(
          retrying: (_) => false,
          cancellingDisabled: (_) => true,
          cancellingEnabled: (_) => true,
          disposing: (_) => true,
          orElse: () => throw StateError(
            'Disallowed state machine state while processing: $state',
          ),
        );

        if (isCancelling) {
          semaphore.release();
          break;
        }

        unawaited(
          operation
              .retry<dynamic>()
              .catchError(_handleError)
              .whenComplete(semaphore.release),
        );
      }
    } finally {
      await semaphore.dispose();
      add(const RetryEvent.processingDone());
    }
  }

  void _handleError(Object error, [StackTrace? stackTrace]) {
    if (!isClosed) {
      addError(error, stackTrace);
    } else {
      Zone.current.handleUncaughtError(error, stackTrace ?? StackTrace.empty);
    }
  }

  Duration _calculateRetryDelay(int backoffIndex) {
    // fibonacci sequence
    const _backoffDurations = [
      Duration(milliseconds: 500),
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
      Duration(seconds: 5),
      Duration(seconds: 8),
      Duration(seconds: 13),
      Duration(seconds: 21),
      Duration(seconds: 34),
      Duration(seconds: 55),
    ];
    return _backoffDurations
        .skip(backoffIndex)
        .followedBy(const [Duration(minutes: 1)]).first;
  }
}
