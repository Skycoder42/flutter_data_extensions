import 'package:clock/clock.dart' as c;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sodium/sodium.dart';

import 'key_info.dart';

part 'key_manager.freezed.dart';

@freezed
class _KeyRotId with _$_KeyRotId {
  const factory _KeyRotId(String type, int keyId) = __KeyRotId;
}

/// An abstract class to generate keys for encryption based on a single master
/// key.
///
/// The class already provides most of the logic for that job. The only
/// method that has to be implemented is the [loadRemoteMasterKey] method to
/// obtain the actual master key.
///
/// You can use the [PassphraseBasedKeyManager] instead to create a key manager
/// that will derive it's master key from a passphrase.
///
/// The key generation works as follows:
/// 1. A `keyId` is either given or generated from the current time (as reported
/// by [clock]). The algorithm generates the id as `"days since epoch" / 30`,
/// which means the id is rotated every 30 days.
/// 2. A `hashingKey` is derived from the `masterKey`.
/// 3. A `subkeyId` is generated from the `type` of the repository. This is done
/// by hashing it using [ShortHash.call] and the previously generated
/// `hashingKey`. To ensure compatibility with the browser, the 64 bit of the
/// hash are split in two 32 bit parts and are x-or-ed with each other.
/// 4. A `repositoryKey` is derived from the `masterKey` using the `subkeyId`.
/// 5. The actual key is derived from the `repositoryKey` using the `keyId`.
///
/// All key derivations make use of [Kdf.deriveFromKey] to derive a new key from
/// the parent key. All derivations use a special context to ensure unique keys.
///
/// **Note:** You can override the `type` to `subkeyId` derivation by overriding
/// [subkeyIdForType].
abstract class KeyManager {
  static const _repositoryKeyContext = 'fds_repo';
  static const _repositoryRotationKeyContext = 'fds_rota';
  static const _repositoryTypeHashKeyContext = 'fds_type';

  static const _daysPerMonth = 30;

  /// The sodium instance used by the key manager.
  final Sodium sodium;

  /// @nodoc
  @visibleForTesting
  final c.Clock clock;

  late final SecureKey _masterKey;

  final _repositoryRotKeys = <_KeyRotId, SecureKey>{};

  /// Default constructor.
  KeyManager({
    required this.sodium,
    c.Clock? clock,
  }) : clock = clock ?? c.clock;

  /// Generates a [SecureKey] of [keyLength] bytes for the given [type].
  ///
  /// Internally, this will generate the key based on the master key, the [type]
  /// and a key id derived from the current time as reported by [clock].
  ///
  /// Both the generated key and the id are returned as [KeyInfo].
  KeyInfo remoteKeyForType(String type, int keyLength) {
    final keyId = _keyIdForDate(clock.now());
    final secureKey = remoteKeyForTypeAndId(type, keyId, keyLength);
    return KeyInfo(keyId, secureKey);
  }

  /// Generates a [SecureKey] of [keyLength] bytes for the given [type] and
  /// [keyId].
  ///
  /// Internally, this will generate the key based on the master key, the [type]
  /// and the given [keyId].
  SecureKey remoteKeyForTypeAndId(String type, int keyId, int keyLength) {
    SecureKey? repositoryKey;
    try {
      return _repositoryRotKeys[_KeyRotId(type, keyId)] ??=
          sodium.crypto.kdf.deriveFromKey(
        masterKey: repositoryKey = _getRepositoryKey(type),
        context: _repositoryRotationKeyContext,
        subkeyId: keyId,
        subkeyLen: keyLength,
      );
    } finally {
      repositoryKey?.dispose();
    }
  }

  /// Initializes the key manager.
  ///
  /// Internally, this will call [loadRemoteMasterKey] to load the master key
  /// required for all other methods.
  ///
  /// **Important:** Make sure to [dispose] all initialized key managers when
  /// not used anymore.
  Future<void> initialize() async {
    // TODO throw better error if initialize was not called or already called
    _masterKey = await loadRemoteMasterKey(sodium.crypto.kdf.keyBytes);
  }

  /// Disposes the key manager.
  ///
  /// This will clear the memory of the master key and all internally cached
  /// derived keys.
  ///
  /// **Important:** This method will crash if [initialize] was not called on
  /// the key manager.
  @mustCallSuper
  void dispose() {
    _masterKey.dispose();
    for (final key in _repositoryRotKeys.values) {
      key.dispose();
    }
    _repositoryRotKeys.clear();
  }

  /// Asynchronously loads the master key for the key manager.
  ///
  /// This method must be implemented by your key manager. It should always
  /// return the same key for the same remote, as otherwise data cannot be
  /// en/decrypted. The key should have a length of [keyLength].
  @protected
  Future<SecureKey> loadRemoteMasterKey(int keyLength);

  /// Derives a key id from a given repository [type].
  ///
  /// The default implementation will use [ShortHash] to generate a number from
  /// the [type].
  @protected
  int subkeyIdForType(String type) {
    assert(
      sodium.crypto.shortHash.bytes == 8,
      'Cannot generate subkeyId if shortHash.bytes is not 8',
    );

    final typeHashingKey = _getTypeHashingKey();
    try {
      final shortHashByteData = sodium.crypto
          .shortHash(
            message: type.toCharArray().unsignedView(),
            key: typeHashingKey,
          )
          .buffer
          .asByteData();
      return shortHashByteData.getUint32(0) ^ shortHashByteData.getUint32(4);
    } finally {
      typeHashingKey.dispose();
    }
  }

  SecureKey _getRepositoryKey(String type) => sodium.crypto.kdf.deriveFromKey(
        masterKey: _masterKey,
        context: _repositoryKeyContext,
        subkeyId: subkeyIdForType(type),
        subkeyLen: sodium.crypto.kdf.keyBytes,
      );

  SecureKey _getTypeHashingKey() => sodium.crypto.kdf.deriveFromKey(
        masterKey: _masterKey,
        context: _repositoryTypeHashKeyContext,
        subkeyId: 0,
        subkeyLen: sodium.crypto.shortHash.keyBytes,
      );

  int _keyIdForDate(DateTime dateTime) {
    final durationSinceEpoch = Duration(
      milliseconds: dateTime.millisecondsSinceEpoch,
    );
    final monthsSinceEpoch = durationSinceEpoch.inDays ~/ _daysPerMonth;
    return monthsSinceEpoch;
  }
}
