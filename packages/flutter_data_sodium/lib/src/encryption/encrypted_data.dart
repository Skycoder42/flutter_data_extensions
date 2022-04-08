import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'uint8list_converter.dart';

part 'encrypted_data.freezed.dart';
part 'encrypted_data.g.dart';

@freezed
class EncryptedData with _$EncryptedData {
  @Uint8ListConverter()
  const factory EncryptedData({
    required String? id,
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required bool hasAd,
    required int keyId,
  }) = _EncryptedData;

  factory EncryptedData.fromJson(Map<String, dynamic> json) =>
      _$EncryptedDataFromJson(json);
}
