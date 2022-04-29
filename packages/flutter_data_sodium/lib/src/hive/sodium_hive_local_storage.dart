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

/// A customization of [HiveLocalStorage] that uses [SodiumHiveCipher] instead
/// of [HiveAesCipher] for local encryption.
///
/// Unlike the normal [HiveLocalStorage] this class always requires an
/// encryption key, as it does not make sense without one. Internally, a fake
/// implementation of a [HiveAesCipher] that wraps [SodiumHiveCipher] is used,
/// to not break the API of the base class.
class SodiumHiveLocalStorage extends HiveLocalStorage {
  final _FakeAesSodiumHiveCipher _sodiumHiveCipher;

  /// Constructor.
  ///
  /// Both [sodium] and [encryptionKey] are required to initialize the storage,
  /// as the storage will always be encrypted. You can use
  /// [SodiumHiveCipher.keyBytes] to create a [SecureKey] of the correct length.
  ///
  /// The [hive], [baseDirFn] and [clear] are simply forwarded to the
  /// [HiveLocalStorage.new] constructor.
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

  /// The internally used [SodiumHiveCipher] instance.
  ///
  /// This will be the same object as [encryptionCipher], as internally a
  /// wrapper class is used that implements both interfaces, but it is in fact
  /// a [SodiumHiveCipher] regarding the actual implementation.
  SodiumHiveCipher get sodiumHiveCipher => _sodiumHiveCipher;

  @override
  HiveAesCipher get encryptionCipher => _sodiumHiveCipher;
}
