import 'package:flutter_data/flutter_data.dart';
import 'package:sodium/sodium.dart';

import 'sodium_hive_local_storage.dart';

typedef CreateFn<T> = T Function(Ref ref);

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
