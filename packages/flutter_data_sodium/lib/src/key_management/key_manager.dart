import 'package:clock/clock.dart' as c;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sodium/sodium.dart';

import 'key_info.dart';

part 'key_manager.freezed.dart';

@freezed
class _KeyRotId with _$_KeyRotId {
  const factory _KeyRotId(String type, int keyId) = __KeyRotId;
}

abstract class KeyManager {
  static const _repositoryKeyContext = 'fds_repo';
  static const _repositoryRotationKeyContext = 'fds_rota';
  static const _repositoryTypeHashKeyContext = 'fds_type';

  static const _daysPerMonth = 30;

  final Sodium sodium;
  final c.Clock clock;

  late final SecureKey _masterKey;

  final _repositoryRotKeys = <_KeyRotId, SecureKey>{};

  KeyManager({
    required this.sodium,
    c.Clock? clock,
  }) : clock = clock ?? c.clock;

  Future<SecureKey> loadLocalKey(int keyLength);

  KeyInfo remoteKeyForType(String type, int keyLength) {
    final keyId = _keyIdForDate(clock.now());
    final secureKey = remoteKeyForTypeAndId(type, keyId, keyLength);
    return KeyInfo(keyId, secureKey);
  }

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

  Future<void> initialize() async {
    _masterKey = await loadRemoteMasterKey(sodium.crypto.kdf.keyBytes);
  }

  void dispose() {
    _masterKey.dispose();
    for (final key in _repositoryRotKeys.values) {
      key.dispose();
    }
    _repositoryRotKeys.clear();
  }

  @protected
  Future<SecureKey> loadRemoteMasterKey(int keyLength);

  SecureKey _getRepositoryKey(String type) => sodium.crypto.kdf.deriveFromKey(
        masterKey: _masterKey,
        context: _repositoryKeyContext,
        subkeyId: _subkeyIdForType(type),
        subkeyLen: sodium.crypto.kdf.keyBytes,
      );

  int _subkeyIdForType(String type) {
    final typeHashingKey = _getTypeHashingKey();
    try {
      return sodium.crypto
          .shortHash(
            message: type.toCharArray().unsignedView(),
            key: typeHashingKey,
          )
          .buffer
          .asByteData()
          .getUint64(0);
    } finally {
      typeHashingKey.dispose();
    }
  }

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
