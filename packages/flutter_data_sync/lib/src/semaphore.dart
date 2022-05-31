import 'dart:async';

import 'dart:collection';

class SemaphoreDisposed implements Exception {
  @override
  String toString() => 'The semaphore has been disposed while waiting on it';
}

class Semaphore {
  static const defaultMaxCount = 10;

  final int _maxCount;

  final _waitingConsumers = Queue<Completer<void>>();

  Completer<void>? _disposeCompleter;
  int _currentCount;

  Semaphore([this._maxCount = defaultMaxCount]) : _currentCount = _maxCount;

  Future<void> acquire() {
    assert(_currentCount >= 0);
    assert(_currentCount <= _maxCount);

    if (_disposeCompleter != null) {
      throw StateError('Semaphore has already been disposed');
    }

    if (_currentCount == 0) {
      final completer = Completer<void>();
      _waitingConsumers.add(completer);
      return completer.future;
    } else {
      _currentCount--;
      return Future.value();
    }
  }

  void release() {
    assert(_currentCount >= 0);
    assert(_currentCount <= _maxCount);

    if (_currentCount == _maxCount) {
      throw StateError('Cannot release any more resources');
    }

    _currentCount++;

    if (_disposeCompleter != null) {
      // ignore: invariant_booleans
      if (_currentCount == _maxCount) {
        assert(!_disposeCompleter!.isCompleted);
        _disposeCompleter!.complete();
      }
      return;
    }

    while (_currentCount > 0 && _waitingConsumers.isNotEmpty) {
      assert(!_waitingConsumers.first.isCompleted);

      _currentCount--;
      _waitingConsumers.removeFirst().complete();
    }
  }

  Future<void> dispose() async {
    if (_disposeCompleter != null) {
      throw StateError('Semaphore has already been disposed');
    }

    // mark as disposed
    _disposeCompleter = Completer();

    // clear all pending consumers
    for (final consumer in _waitingConsumers) {
      assert(!consumer.isCompleted);
      consumer.completeError(SemaphoreDisposed(), StackTrace.current);
    }
    _waitingConsumers.clear();

    // wait until resources have been released
    if (_currentCount == _maxCount) {
      _disposeCompleter!.complete();
      return;
    } else {
      await _disposeCompleter!.future;
      assert(_currentCount == _maxCount);
    }
  }
}
