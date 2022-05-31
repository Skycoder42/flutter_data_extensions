import 'dart:async';

import 'package:flutter_data/flutter_data.dart';

import 'retry_state_machine.dart';

late final syncControllerProvider = Provider.family(
  (ref, Map<String, Provider<Repository>> repositoryProviders) =>
      SyncController(
    read: ref.read,
    pendingOfflineTypesNotifier:
        ref.watch(pendingOfflineTypesProvider.notifier),
    repositoryProviders: repositoryProviders,
    retryStateMachine: ref.watch(retryStateMachineProvider),
  ),
);

typedef ReadRepositoryFn = Repository Function(
  ProviderBase<Repository> provider,
);

class SyncController {
  final ReadRepositoryFn read;
  final DelayedStateNotifier<Set<String>> pendingOfflineTypesNotifier;
  final Map<String, Provider<Repository>> repositoryProviders;
  final RetryStateMachine retryStateMachine;

  late RemoveListener _removeUpdateOfflineOperationsListener;

  SyncController({
    required this.read,
    required this.pendingOfflineTypesNotifier,
    required this.repositoryProviders,
    required this.retryStateMachine,
  }) {
    _removeUpdateOfflineOperationsListener =
        pendingOfflineTypesNotifier.addListener(_updateOfflineOperations);
  }

  RemoveErrorListenerCb addErrorListener(OnErrorCb onError) =>
      retryStateMachine.addErrorListener(onError);

  bool get enabled => retryStateMachine.enabled;
  set enabled(bool enabled) => retryStateMachine.enabled = enabled;

  Future<void> dispose() async {
    _removeUpdateOfflineOperationsListener();
    await retryStateMachine.close();
  }

  void _updateOfflineOperations(Set<String> types) {
    final offlineOperations = types
        .map((type) => repositoryProviders[type])
        .whereType<Provider<Repository>>()
        .expand((provider) => read(provider).offlineOperations)
        .toSet();
    retryStateMachine.updatePendingOfflineOperations(offlineOperations);
  }
}
