import 'dart:convert';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';

import '../key_management/key_manager.dart';
import 'encrypted_data.dart';

class DataCipher {
  static const _idJsonKey = 'id';

  final Sodium sodium;
  final KeyManager keyManager;

  const DataCipher({
    required this.sodium,
    required this.keyManager,
  });

  EncryptedData encrypt(String type, Map<String, dynamic> jsonData) {
    final id = jsonData[_idJsonKey] as Object?;
    final jsonDataWithoutId = <String, dynamic>{
      for (final entry in jsonData.entries)
        if (entry.key != _idJsonKey) entry.key: entry.value,
    };

    final keyInfo =
        keyManager.remoteKeyForType(type, sodium.crypto.aead.keyBytes);
    final nonce = sodium.randombytes.buf(sodium.crypto.aead.nonceBytes);

    final cipherData = sodium.crypto.aead.encryptDetached(
      message: _jsonToBytes(jsonDataWithoutId),
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
    final secureKey = keyManager.remoteKeyForTypeAndId(
      type,
      encryptedData.keyId,
      sodium.crypto.aead.keyBytes,
    );

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
        _idJsonKey: encryptedData.id,
      };
    } else {
      return plainJson;
    }
  }

  Uint8List? _getAdForId(Object? id, [bool? hasAd]) {
    if (hasAd ?? id != null) {
      assert(
        id != null,
        'Invalid cipher data. Expected an id but none was given.',
      );

      return _jsonToBytes(id);
    } else {
      return null;
    }
  }

  Uint8List _jsonToBytes(dynamic jsonData) =>
      json.encode(jsonData).toCharArray().unsignedView();

  dynamic _bytesToJson(Uint8List bytes) =>
      json.decode(bytes.signedView().toDartString());
}
