import 'package:flutter_data/flutter_data.dart';
import 'package:sodium/sodium.dart';

import 'sodium_hive_local_storage.dart';

/// A generic function that creates an instance of [T] using a [ref].
typedef CreateFn<T> = T Function(Ref ref);

/// Creates an override for [hiveLocalStorageProvider] using sodium encryption.
///
/// This method does the same as the auto-generated variant in `main.data.dart`,
/// but instead of using the standard (non audited) encryption of hive, [sodium]
/// is used to encrypt data locally.
///
/// Both [sodium] and the [encryptionKey] are required as this method does not
/// make sense if encryption is not used. The length of the key must be
/// [SodiumHiveCipher.keyBytes].
///
/// [baseDirFn] is also required, as unlike the auto-generated variant, this
/// here is not aware of a possibly installed path_provider. If you want to
/// initially clear all opened repositories, you can set [clear] to true.
///
/// Internally, this method overrides the provider with a
/// [SodiumHiveLocalStorage].
Override configureRepositoryLocalStorageSodium({
  required CreateFn<Sodium> sodium,
  required CreateFn<SecureKey> encryptionKey,
  required FutureFn<String> baseDirFn,
  bool? clear,
}) =>
    hiveLocalStorageProvider.overrideWithProvider(
      Provider(
        (ref) => SodiumHiveLocalStorage(
          hive: ref.read(hiveProvider),
          sodium: sodium(ref),
          encryptionKey: encryptionKey(ref),
          baseDirFn: baseDirFn,
          clear: clear,
        ),
      ),
    );
