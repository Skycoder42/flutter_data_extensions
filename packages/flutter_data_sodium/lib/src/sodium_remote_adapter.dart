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
  DeserializedData<T> deserialize(Object? data, {String? key}) =>
      super.deserialize(
        data is Map<String, dynamic>
            ? cipher.decrypt(type, EncryptedData.fromJson(data))
            : data,
        key: key,
      );
}
