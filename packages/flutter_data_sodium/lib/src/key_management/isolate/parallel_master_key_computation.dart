import 'dart:async';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import '../passphrase_based_key_manager.dart';
import 'parallel_computation_failure.dart';

typedef CreateSodiumFn = FutureOr<Sodium> Function();

class _PortWithSub {
  final ReceivePort recvPort;
  final StreamSubscription sub;

  const _PortWithSub(this.recvPort, this.sub);

  Future<void> cancel() => sub.cancel();
}

mixin ParallelMasterKeyComputation on PassphraseBasedKeyManager {
  @visibleForTesting
  static const isolateDebugName = 'ParallelMasterKeyComputation._isolateMain';

  @protected
  CreateSodiumFn get sodiumFactory;

  @override
  @protected
  @nonVirtual
  Future<SecureKey> deriveKey(
    MasterKeyComponents masterKeyComponents,
    int keyLength,
  ) async {
    final computationCompleter = Completer<SecureKey>();

    _PortWithSub? error;
    _PortWithSub? result;
    _PortWithSub? init;
    Isolate? isolate;
    try {
      error = _createPortWithListener(
        'error',
        computationCompleter,
        _onIsolateError,
      );
      result = _createPortWithListener(
        'result',
        computationCompleter,
        _onIsolateResult,
      );
      init = _createPortWithListener(
        'init',
        computationCompleter,
        (completer, dynamic message) {
          if (message is! SendPort) {
            _handleError(
              completer,
              StateError(
                'First message of the computation isolate must be a send port',
              ),
            );
            return;
          }

          message.send([
            sodiumFactory, // TODO test with sodium instance
            masterKeyComponents,
            keyLength,
            result!.recvPort.sendPort,
          ]);
        },
      );

      isolate = await Isolate.spawn(
        _isolateMain,
        init.recvPort.sendPort,
        debugName: isolateDebugName,
        onError: error.recvPort.sendPort,
        errorsAreFatal: true,
      );
      return await computationCompleter.future;
    } catch (e) {
      isolate?.kill();
      rethrow;
    } finally {
      await init?.cancel();
      await result?.cancel();
      await error?.cancel();
    }
  }

  static Future<void> _isolateMain(SendPort initSendPort) async {
    final messageRecvPort = ReceivePort(
      '$isolateDebugName.message',
    );
    initSendPort.send(messageRecvPort.sendPort);

    final message = await messageRecvPort.first as List<dynamic>;
    assert(message.length == 4);
    final sodiumFactory = message[0] as CreateSodiumFn;
    final masterKeyComponents = message[1] as MasterKeyComponents;
    final keyLength = message[2] as int;
    final resultSendPort = message[3] as SendPort;

    final masterKey = PassphraseBasedKeyManager.computeMasterKey(
      sodium: await sodiumFactory(),
      masterKeyComponents: masterKeyComponents,
      keyLength: keyLength,
    );

    try {
      Isolate.exit(resultSendPort, masterKey);
    } catch (e) {
      masterKey.dispose();
      rethrow;
    }
  }

  static _PortWithSub _createPortWithListener<T>(
    String name,
    Completer<T> completer,
    void Function(Completer<T> completer, dynamic message) onData,
  ) {
    final port = ReceivePort('$isolateDebugName.name');
    return _PortWithSub(
      port,
      port.listen(
        (dynamic message) => onData(completer, message),
        onError: (Object error, StackTrace? message) =>
            _handleError(completer, error, message),
        cancelOnError: true,
      ),
    );
  }

  static void _onIsolateResult(
    Completer<SecureKey> completer,
    dynamic message,
  ) {
    if (message is! SecureKey) {
      _handleError(completer, ParallelComputationFailure(message.toString()));
      return;
    }

    if (!completer.isCompleted) {
      completer.complete(message);
    } else {
      message.dispose();
      _handleError(
        completer,
        StateError('Isolate sent more the one computed key'),
        StackTrace.current,
      );
    }
  }

  static void _onIsolateError(
    Completer<SecureKey> completer,
    dynamic message,
  ) {
    final messageList = message as List;
    final error = messageList[0] as String;
    final stackTraceString = messageList[1] as String?;
    final stackTrace = stackTraceString == null
        ? null
        : StackTrace.fromString(stackTraceString);
    _handleError(completer, ParallelComputationFailure(error), stackTrace);
  }

  static void _handleError(
    Completer<dynamic> completer,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    } else {
      Zone.current.handleUncaughtError(error, stackTrace ?? StackTrace.empty);
    }
  }
}
