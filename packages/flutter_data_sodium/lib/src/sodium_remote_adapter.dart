import 'package:flutter_data/flutter_data.dart';
import 'package:sodium/sodium.dart';

import 'encryption/data_cipher.dart';
import 'encryption/encrypted_data.dart';
import 'key_management/key_manager.dart';

mixin SodiumRemoteAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  Sodium get sodium;

  KeyManager get keyManager;

  late final DataCipher cipher = DataCipher(
    sodium: sodium,
    keyManager: keyManager,
  );

  @override
  Map<String, dynamic> serialize(T model) =>
      cipher.encrypt(type, super.serialize(model)).toJson();

  @override
  DeserializedData<T> deserialize(Object? data, {String? key}) {
    if (data == null || data == '') {
      return super.deserialize(null, key: key);
    } else if (data is Iterable) {
      return super.deserialize(
        data.map<dynamic>(
          (dynamic e) => cipher.decrypt(type, _formatCast(e)),
        ),
        key: key,
      );
    } else {
      return super.deserialize(
        cipher.decrypt(type, _formatCast(data)),
        key: key,
      );
    }
  }

  EncryptedData _formatCast(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw FormatException(
        'Invalid JSON-data. Must be an EncryptedData object',
        data.toString(),
      );
    }
    return EncryptedData.fromJson(data);
  }
}
