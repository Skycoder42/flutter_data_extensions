import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import 'encryption/data_cipher.dart';
import 'encryption/encrypted_data.dart';
import 'key_management/key_manager.dart';

/// A special [RemoteAdapter] that adds an End-To-End-Encryption layer to all
/// your requests.
///
/// The adapter will use the [keyManager] and [sodium] to encrypt all outgoing
/// request data and to decrypt all incoming request data. The [Aead] algorithm
/// of [Sodium] is used to archive this. Unique keys are transparently generate
/// from a master key and rotated every 30 days to ensure a maximum security.
mixin SodiumRemoteAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  /// The [Sodium] instance used to perform all cryptographic operations.
  Sodium get sodium;

  /// A [KeyManager] that is used to obtain the encryption keys.
  KeyManager get keyManager;

  /// @nodoc
  @visibleForTesting
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
