import 'dart:async';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import 'passphrase_based_key_manager.dart';

typedef CreateSodiumFn = FutureOr<Sodium> Function();

class ParallelComputationFailure implements Exception {
  final String originalExceptionMessage;

  ParallelComputationFailure(this.originalExceptionMessage);

  @override
  String toString() => originalExceptionMessage;
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

    StreamSubscription? errorSub;
    Isolate? isolate;
    try {
      final initRecvPort = ReceivePort('$isolateDebugName.init');
      final errorRecvPort = ReceivePort('$isolateDebugName.error');
      errorSub = errorRecvPort.listen(
        (dynamic message) {
          final messageList = message as List;
          final error = messageList[0] as String;
          final stackTraceString = messageList[1] as String?;
          final stackTrace = stackTraceString == null
              ? null
              : StackTrace.fromString(stackTraceString);

          if (!computationCompleter.isCompleted) {
            computationCompleter.completeError(
              ParallelComputationFailure(error),
              stackTrace,
            );
          } else {
            Zone.current.handleUncaughtError(
              ParallelComputationFailure(error),
              stackTrace ?? StackTrace.empty,
            );
          }
        },
      );

      isolate = await Isolate.spawn(
        _isolateMain,
        initRecvPort.sendPort,
        debugName: isolateDebugName,
        onError: errorRecvPort.sendPort,
        errorsAreFatal: true,
      );

      final messageSendPort = await initRecvPort.first as SendPort;
      final resultRecvPort = ReceivePort('$isolateDebugName.result');
      messageSendPort.send([
        sodiumFactory,
        masterKeyComponents,
        keyLength,
        resultRecvPort.sendPort,
      ]);

      // ignore: unawaited_futures
      resultRecvPort.first.then((dynamic secureKey) {
        if (!computationCompleter.isCompleted) {
          computationCompleter.complete(secureKey as SecureKey);
        }
      }).catchError((Object error, StackTrace? stackTrace) {
        if (!computationCompleter.isCompleted) {
          computationCompleter.completeError(error, stackTrace);
        } else {
          Zone.current.handleUncaughtError(
            error,
            stackTrace ?? StackTrace.empty,
          );
        }
      });

      return await computationCompleter.future;
    } catch (e) {
      isolate?.kill();
      rethrow;
    } finally {
      await errorSub?.cancel();
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
}
