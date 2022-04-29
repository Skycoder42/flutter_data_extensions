import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import 'passphrase_based_key_manager.dart';

/// An asynchronous static or top level method that returns a sodium instance.
typedef CreateSodiumFn = FutureOr<Sodium> Function();

/// A method to be executed asynchronously
typedef ComputeCallback<Q, R> = FutureOr<R> Function(Q message);

class _ComputeMasterKeyMessage {
  final CreateSodiumFn createSodiumFn;
  final MasterKeyComponents masterKeyComponents;
  final int keyLength;

  const _ComputeMasterKeyMessage(
    this.createSodiumFn,
    this.masterKeyComponents,
    this.keyLength,
  );
}

/// A mixin on [PassphraseBasedKeyManager] to allow key derivation in an
/// isolate.
///
/// This mixin can be used to let the key manager derive the master key from
/// the passphrase on a separate isolate to prevent the application (typically
/// UI) from freezing.
///
/// This mixin still has abstract methods, as this package does not depend on
/// flutter and thus leaves it up to the implementer to actually execute the
/// code on the separate isolate. However, in case you are using flutter, you
/// can simply copy the following snippted:
///
/// ```dart
/// import 'package:flutter/foundation.dart' as ff;
/// import 'package:sodium_libs/sodium_libs.dart';
///
/// class MyKeyManager extends PassphraseBasedKeyManager
///     with ParallelMasterKeyComputation {
///   @override
///   CreateSodiumFn get sodiumFactory => SodiumInit.init;
///
///   @override
///   Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) =>
///       ff.compute(
///         callback,
///         message,
///         debugLabel: '$MyKeyManager.compute',
///       );
///
///   @override
///   FutureOr<MasterKeyComponents> loadMasterKeyComponents() {
///     // TODO: implement loadMasterKeyComponents
///     throw UnimplementedError();
///   }
/// }
/// ```
mixin ParallelMasterKeyComputation on PassphraseBasedKeyManager {
  static Future<dynamic> _runInIsolate(_ComputeMasterKeyMessage message) async {
    final sodium = await message.createSodiumFn();
    final key = PassphraseBasedKeyManager.computeMasterKey(
      sodium: sodium,
      masterKeyComponents: message.masterKeyComponents,
      keyLength: message.keyLength,
    );
    return key.nativeHandle;
  }

  /// A getter that must return a static or top level function that
  /// asynchronously returns a sodium instance.
  ///
  /// In case of a flutter application, you can simply return `SodiumInit.init`.
  @protected
  CreateSodiumFn get sodiumFactory;

  /// The compute method which actually runs the parallel computation.
  ///
  /// The implementation should run [callback] on a new isolate and pass
  /// [message] to it. When finished, the result of [callback] should be
  /// returned.
  ///
  /// In case of a flutter application, you can simply call the flutter compute
  /// method from within this one: `ff.compute(callback, message);`
  @protected
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message);

  @override
  @protected
  @nonVirtual
  Future<SecureKey> deriveKey(
    MasterKeyComponents masterKeyComponents,
    int keyLength,
  ) async {
    final dynamic nativeHandle =
        await compute<_ComputeMasterKeyMessage, dynamic>(
      _runInIsolate,
      _ComputeMasterKeyMessage(
        sodiumFactory,
        masterKeyComponents,
        keyLength,
      ),
    );
    return SecureKey.fromNativeHandle(sodium, nativeHandle);
  }
}
