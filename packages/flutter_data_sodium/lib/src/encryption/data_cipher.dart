import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';

import '../key_management/key_manager.dart';
import 'encrypted_data.dart';

class DataCipher {
  final Sodium sodium;
  final KeyManager keyManager;

  const DataCipher({
    required this.sodium,
    required this.keyManager,
  });

  EncryptedData encrypt(String type, Map<String, dynamic> jsonData) {
    final id = jsonData.remove('id') as String?;
    final keyInfo = keyManager.keyForType(type);
    final nonce = sodium.randombytes.buf(sodium.crypto.aead.nonceBytes);

    final cipherData = sodium.crypto.aead.encryptDetached(
      message: _jsonToBytes(jsonData),
      nonce: nonce,
      key: keyInfo.secureKey,
      additionalData: _getAdForId(id),
    );

    return EncryptedData(
      id: id,
      cipherText: cipherData.cipherText,
      mac: cipherData.mac,
      nonce: nonce,
      hasAd: id != null,
      keyId: keyInfo.keyId,
    );
  }

  dynamic decrypt(String type, EncryptedData encryptedData) {
    final secureKey = keyManager.keyForTypeAndId(type, encryptedData.keyId);

    final plainData = sodium.crypto.aead.decryptDetached(
      cipherText: encryptedData.cipherText,
      mac: encryptedData.mac,
      nonce: encryptedData.nonce,
      key: secureKey,
      additionalData: _getAdForId(encryptedData.id, encryptedData.hasAd),
    );

    final dynamic plainJson = _bytesToJson(plainData);
    if (plainJson is Map<String, dynamic>) {
      return <String, dynamic>{
        ...plainJson,
        'id': encryptedData.id,
      };
    } else {
      return plainJson;
    }
  }

  Uint8List? _getAdForId(String? id, [bool? hasAd]) {
    if (hasAd ?? id != null) {
      assert(
        id != null,
        'Invalid cipher data. Expected an id but none was given',
      );

      return _stringToBytes(id!);
    } else {
      return null;
    }
  }

  Uint8List _stringToBytes(String data) => data.toCharArray().unsignedView();

  String _bytesToString(Uint8List bytes) => bytes.signedView().toDartString();

  Uint8List _jsonToBytes(dynamic jsonData) =>
      _stringToBytes(json.encode(jsonData));

  dynamic _bytesToJson(Uint8List bytes) => json.decode(_bytesToString(bytes));
}
