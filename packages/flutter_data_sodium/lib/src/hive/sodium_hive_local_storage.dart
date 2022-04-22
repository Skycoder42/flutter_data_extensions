import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_data/flutter_data.dart';
import 'package:hive/hive.dart';
import 'package:sodium/sodium.dart';

import '../../flutter_data_sodium.dart';

class _FakeAesSodiumHiveCipher extends SodiumHiveCipher
    implements HiveAesCipher {
  _FakeAesSodiumHiveCipher({
    required Sodium sodium,
    required SecureKey encryptionKey,
  }) : super(
          sodium: sodium,
          encryptionKey: encryptionKey,
        );

  @override
  Uint8List generateIv() => sodium.randombytes.buf(
        sodium.crypto.secretBox.nonceBytes,
      );
}

class SodiumHiveLocalStorage extends HiveLocalStorage {
  final _FakeAesSodiumHiveCipher _sodiumHiveCipher;

  SodiumHiveLocalStorage({
    required HiveInterface hive,
    required Sodium sodium,
    required SecureKey encryptionKey,
    FutureOr<String> Function()? baseDirFn,
    bool? clear,
  })  : _sodiumHiveCipher = _FakeAesSodiumHiveCipher(
          sodium: sodium,
          encryptionKey: encryptionKey,
        ),
        super(
          hive: hive,
          baseDirFn: baseDirFn,
          clear: clear,
        );

  SodiumHiveCipher get sodiumHiveCipher => _sodiumHiveCipher;

  @override
  HiveAesCipher get encryptionCipher => _sodiumHiveCipher;
}
