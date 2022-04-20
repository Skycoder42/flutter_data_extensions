import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sodium/sodium.dart';

import 'key_manager.dart';

part 'passphrase_based_key_manager.freezed.dart';

@freezed
class MasterKeyComponents with _$MasterKeyComponents {
  const factory MasterKeyComponents({
    required String password,
    required Uint8List salt,
    int? opsLimit,
    int? memLimit,
  }) = _MasterKeyComponents;
}

abstract class PassphraseBasedKeyManager extends KeyManager {
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

  PassphraseBasedKeyManager({
    required Sodium sodium,
    Clock? clock,
  }) : super(
          sodium: sodium,
          clock: clock,
        );

  @protected
  Future<MasterKeyComponents> loadMasterKeyComponents();

  @override
  @protected
  Future<SecureKey> loadRemoteMasterKey(int keyLength) async {
    final masterKeyComponents = await loadMasterKeyComponents();
    final masterKey = await deriveKey(masterKeyComponents, keyLength);
    return masterKey;
  }

  @protected
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
