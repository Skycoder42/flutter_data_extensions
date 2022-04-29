import 'dart:typed_data';

import 'package:hive/hive.dart';
// ignore: implementation_imports
import 'package:hive/src/crypto/crc32.dart' as hive_internal;
import 'package:sodium/sodium.dart';

/// An implementation of [HiveCipher] that uses the [SecretBox] for encryption.
///
/// You can use this as alternative to [HiveAesCipher] in case you do not want
/// to rely on the correctness of their AES implementation. This class instead
/// uses the [SecretBox.easy] algorithms to encrypt data for storage.
class SodiumHiveCipher implements HiveCipher {
  /// The length (in bytes) the [encryptionKey] must be.
  ///
  /// This static method uses [sodium] to get the correct key length at
  /// runtime. You can use it to generate an encryption key of the correct
  /// length.
  static int keyBytes(Sodium sodium) => sodium.crypto.secretBox.keyBytes;

  /// The sodium instance the cipher uses.
  final Sodium sodium;

  /// The secret key used for encryption and decryption.
  final SecureKey encryptionKey;

  /// Constructor.
  SodiumHiveCipher({
    required this.sodium,
    required this.encryptionKey,
  }) : assert(
          encryptionKey.length == keyBytes(sodium),
          'encryptionKey must have a length of ${keyBytes(sodium)}',
        );

  @override
  int calculateKeyCrc() => hive_internal.Crc32.compute(
        encryptionKey.runUnlockedSync(
          (encryptionKeyData) => sodium.crypto.genericHash(
            message: encryptionKeyData,
            outLen: sodium.crypto.genericHash.bytesMax,
          ),
        ),
      );

  @override
  int maxEncryptedSize(Uint8List inp) => _cipherLength(inp.length);

  @override
  int encrypt(
    Uint8List inp,
    int inpOff,
    int inpLength,
    Uint8List out,
    int outOff,
  ) {
    _validateInp(inp, inpOff, inpLength);
    _validateOut(out, outOff, _cipherLength(inpLength));

    final nonce = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);
    out.setAll(outOff, nonce);

    final cipher = sodium.crypto.secretBox.easy(
      message: Uint8List.sublistView(inp, inpOff, inpOff + inpLength),
      nonce: nonce,
      key: encryptionKey,
    );
    out.setAll(outOff + nonce.length, cipher);

    return nonce.length + cipher.length;
  }

  @override
  int decrypt(
    Uint8List inp,
    int inpOff,
    int inpLength,
    Uint8List out,
    int outOff,
  ) {
    _validateInp(inp, inpOff, inpLength);
    _validateCipher(inpLength);
    _validateOut(out, outOff, _plainLength(inpLength));

    final nonce = Uint8List.sublistView(
      inp,
      inpOff,
      inpOff + sodium.crypto.secretBox.nonceBytes,
    );
    final cipher = Uint8List.sublistView(
      inp,
      inpOff + nonce.length,
      inpOff + inpLength,
    );

    final plain = sodium.crypto.secretBox.openEasy(
      cipherText: cipher,
      nonce: nonce,
      key: encryptionKey,
    );
    out.setAll(outOff, plain);
    return plain.length;
  }

  int _cipherLength(int inpLength) =>
      inpLength +
      sodium.crypto.secretBox.nonceBytes +
      sodium.crypto.secretBox.macBytes;

  int _plainLength(int inpLength) =>
      inpLength -
      sodium.crypto.secretBox.nonceBytes -
      sodium.crypto.secretBox.macBytes;

  void _validateInp(Uint8List inp, int inpOff, int inpLength) {
    if (inp.length < inpOff + inpLength) {
      throw ArgumentError.value(
        inp.length,
        'inp',
        'inp is to short for specified inpOff and inpLength. '
            'Should be at least ${inpOff + inpLength} but was',
      );
    }
  }

  void _validateOut(Uint8List out, int outOff, int outLength) {
    if (out.length < outOff + outLength) {
      throw ArgumentError.value(
        out.length,
        'out',
        'out is to short for specified outOff and inpLength. '
            'Should be at least ${outOff + outLength} but was',
      );
    }
  }

  void _validateCipher(int inpLength) {
    final minBytes =
        sodium.crypto.secretBox.nonceBytes + sodium.crypto.secretBox.macBytes;
    if (inpLength < minBytes) {
      throw ArgumentError.value(
        inpLength,
        'inpLength',
        'inp is to short for to contain valid cipher data. '
            'Should be at least $minBytes but was',
      );
    }
  }
}
