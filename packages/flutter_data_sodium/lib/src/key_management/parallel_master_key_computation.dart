import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import 'passphrase_based_key_manager.dart';

typedef CreateSodiumFn = FutureOr<Sodium> Function();

typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

class _IsolateMessage {
  final CreateSodiumFn createSodiumFn;
  final MasterKeyComponents masterKeyComponents;
  final int keyLength;

  const _IsolateMessage(
    this.createSodiumFn,
    this.masterKeyComponents,
    this.keyLength,
  );
}

mixin ParallelMasterKeyComputation on PassphraseBasedKeyManager {
  static Future<dynamic> _runInIsolate(_IsolateMessage message) async {
    final sodium = await message.createSodiumFn();
    final key = PassphraseBasedKeyManager.computeMasterKey(
      sodium: sodium,
      masterKeyComponents: message.masterKeyComponents,
      keyLength: message.keyLength,
    );
    return key.nativeHandle;
  }

  @protected
  CreateSodiumFn get sodiumFactory;

  @protected
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message);

  @override
  @protected
  @nonVirtual
  Future<SecureKey> deriveKey(
    MasterKeyComponents masterKeyComponents,
    int keyLength,
  ) async {
    final dynamic nativeHandle = await compute<_IsolateMessage, dynamic>(
      _runInIsolate,
      _IsolateMessage(
        sodiumFactory,
        masterKeyComponents,
        keyLength,
      ),
    );
    return SecureKey.fromNativeHandle(sodium, nativeHandle);
  }
}
