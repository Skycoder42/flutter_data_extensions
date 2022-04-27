// ignore: test_library_import
import 'dart:typed_data';

import 'package:clock/clock.dart';
// ignore: test_library_import
import 'package:flutter_data_sodium/flutter_data_sodium.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class _TestKeyManager extends KeyManager {
  final SecureKey masterKey;

  _TestKeyManager({
    required Sodium sodium,
    required this.masterKey,
    Clock? clock,
  }) : super(
          sodium: sodium,
          clock: clock,
        );

  @override
  Future<SecureKey> loadRemoteMasterKey(int keyLength) {
    expect(keyLength, masterKey.length);
    return Future.value(masterKey);
  }
}

mixin KeyManagerSetup {
  Future<KeyManager> loadKeyManager(
    Sodium sodium,
    Uint8List masterKeyBytes,
  ) async {
    final keyManager = _TestKeyManager(
      sodium: sodium,
      masterKey: SecureKey.fromList(sodium, masterKeyBytes),
    );
    await keyManager.initialize();
    addTearDown(keyManager.dispose);
    return keyManager;
  }
}
