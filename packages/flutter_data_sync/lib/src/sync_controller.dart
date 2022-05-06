import 'dart:async';

import 'package:flutter_data/flutter_data.dart';

late final syncControllerProvider = Provider.family(
  (ref, Map<String, Provider<Repository>> repositoryProviders) =>
      SyncController(
    ref: ref,
    pendingOfflineTypesNotifier:
        ref.watch(pendingOfflineTypesProvider.notifier),
    repositoryProviders: repositoryProviders,
  ),
);

class SyncController {
  final Ref ref;
  final DelayedStateNotifier<Set<String>> pendingOfflineTypesNotifier;
  final Map<String, Provider<Repository>> repositoryProviders;

  late RemoveListener _removeUpdateOfflineOperationsListener;
  late StreamController<void> _errorStreamController;
  var _pendingOfflineOperations = const <OfflineOperation>{};
  var _isProcessing = false;
  Completer<void>? _disposeCompleter;

  SyncController({
    required this.ref,
    required this.pendingOfflineTypesNotifier,
    required this.repositoryProviders,
  }) {
    _errorStreamController = StreamController.broadcast();
    _removeUpdateOfflineOperationsListener =
        pendingOfflineTypesNotifier.addListener(_updateOfflineOperations);
  }

  Stream<void> get errorStream => _errorStreamController.stream;

  Future<void> Function() addErrorListener(Function listener) => errorStream
      .listen(
        null,
        onError: listener,
        cancelOnError: false,
      )
      .cancel;

  Future<void> dispose() async {
    _disposeCompleter = Completer();
    _removeUpdateOfflineOperationsListener();
    _pendingOfflineOperations.clear();
    await _disposeCompleter!.future;
    await _errorStreamController.close();
  }

  void _updateOfflineOperations(Set<String> types) {
    _pendingOfflineOperations = types
        .map((type) => repositoryProviders[type])
        .whereType<Provider<Repository>>()
        .expand((provider) => ref.read(provider).offlineOperations)
        .toSet();

    if (!_isProcessing) {
      _processNextOfflineOperation();
    }
  }

  Future<void> _processNextOfflineOperation() async {
    assert(!_isProcessing);
    try {
      _isProcessing = true;
      while (_pendingOfflineOperations.isNotEmpty) {
        // abort loop if disposition was requested
        if (_disposeCompleter != null) {
          if (!_disposeCompleter!.isCompleted) {
            _disposeCompleter!.complete();
          }
          break;
        }

        final operation = _takeNextOfflineOperation();
        await operation.retry<dynamic>().catchError(_handleError);
      }
    } finally {
      _isProcessing = false;
    }
  }

  OfflineOperation<DataModel<dynamic>> _takeNextOfflineOperation() {
    assert(_pendingOfflineOperations.isNotEmpty);
    final operation = _pendingOfflineOperations.first;
    final didRemove = _pendingOfflineOperations.remove(operation);
    assert(didRemove);
    return operation;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (!_errorStreamController.isClosed) {
      _errorStreamController.addError(error, stackTrace);
    } else {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }
}
