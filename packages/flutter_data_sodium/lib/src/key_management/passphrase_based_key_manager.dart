import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sodium/sodium.dart';

import 'key_manager.dart';

part 'passphrase_based_key_manager.freezed.dart';

/// A collection of properties that are used to generate a master key.
@freezed
class MasterKeyComponents with _$MasterKeyComponents {
  /// Default constructor.
  const factory MasterKeyComponents({
    /// The password to derive the master key from.
    required String password,

    /// A salt to be combined with the password.
    ///
    /// This salt exists to ensure that two different users that use the same
    /// password still get different keys. The salt must be [Pwhash.saltBytes]
    /// long and must stay the same for every user. Typically, you either store
    /// it globally for each user or derive it from public information about the
    /// user.
    required Uint8List salt,

    /// Optional setting for opsLimit.
    ///
    /// By default [Pwhash.opsLimitSensitive] is used.
    int? opsLimit,

    /// Optional setting for memLimit.
    ///
    /// By default [Pwhash.memLimitSensitive] is used.
    int? memLimit,
  }) = _MasterKeyComponents;
}

/// An extension of the standard [KeyManager] that generates it's master key
/// based of a passphrase.
///
/// This class implements [loadRemoteMasterKey] by deriving the key from a
/// passphrase as well as other parameters. Those parameters must be provided
/// by implementing the [loadMasterKeyComponents] method.
///
/// **Note:** The used generation algorithm is very computation heavy and thus
/// might freeze the UI for a few seconds. This is by design, to ensure keys
/// cannot easily be brute-forced by just guessing passwords. To prevent the
/// ui from freezing, you should use the [ParallelMasterKeyComputation] mixin
/// to run the code on a separate isolate.
abstract class PassphraseBasedKeyManager extends KeyManager {
  /// @nodoc
  @internal
  static SecureKey computeMasterKey({
    required Sodium sodium,
    required MasterKeyComponents masterKeyComponents,
    required int keyLength,
  }) =>
      sodium.crypto.pwhash(
        outLen: keyLength,
        password: masterKeyComponents.password.toCharArray(),
        salt: masterKeyComponents.salt,
        opsLimit: masterKeyComponents.opsLimit ??
            sodium.crypto.pwhash.opsLimitSensitive,
        memLimit: masterKeyComponents.memLimit ??
            sodium.crypto.pwhash.memLimitSensitive,
      );

  /// Default constructor.
  PassphraseBasedKeyManager({
    required Sodium sodium,
    Clock? clock,
  }) : super(
          sodium: sodium,
          clock: clock,
        );

  /// Asynchronously loads the master key components to derive the key from.
  ///
  /// This method must be implemented by your key manager. It should always
  /// return the same components for the same remote, as otherwise data cannot
  /// be en/decrypted. Typically, this means you will have to provide the salt,
  /// opsLimit and memLimit consistently and let the user enter the passphrase.
  @protected
  FutureOr<MasterKeyComponents> loadMasterKeyComponents();

  @override
  @protected
  @nonVirtual
  Future<SecureKey> loadRemoteMasterKey(int keyLength) async {
    final masterKeyComponents = await loadMasterKeyComponents();
    final masterKey = await deriveKey(masterKeyComponents, keyLength);
    return masterKey;
  }

  /// @nodoc
  @internal
  @visibleForOverriding
  Future<SecureKey> deriveKey(
    MasterKeyComponents masterKeyComponents,
    int keyLength,
  ) =>
      Future(
        () => computeMasterKey(
          sodium: sodium,
          masterKeyComponents: masterKeyComponents,
          keyLength: keyLength,
        ),
      );
}
