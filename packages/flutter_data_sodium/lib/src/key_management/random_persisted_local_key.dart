import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import 'key_manager.dart';

mixin RandomPersistedLocalKey on KeyManager {
  @override
  @nonVirtual
  Future<SecureKey> loadLocalKey(int keyLength) async {
    final key = await loadKeyFromStorage();
    if (key != null) {
      _validateStoredKey(key, keyLength);
      return key;
    }

    final newKey = sodium.secureRandom(keyLength);
    try {
      await persisKeyInStorage(newKey);
      return newKey;
    } catch (e) {
      newKey.dispose();
      rethrow;
    }
  }

  @protected
  Future<SecureKey?> loadKeyFromStorage();

  @protected
  Future<void> persisKeyInStorage(SecureKey secureKey);
}

void _validateStoredKey(SecureKey key, int keyLength) {
  if (key.length != keyLength) {
    final actualKeyLength = key.length;
    key.dispose();

    throw StateError(
      'Invalid stored key! Expected key with length of $keyLength, '
      'but got a key with length $actualKeyLength',
    );
  }
}
