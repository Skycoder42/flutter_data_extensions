import 'package:flutter_data/flutter_data.dart';
import 'package:sodium/sodium.dart';

import 'sodium_hive_local_storage.dart';

typedef SodiumFn = Sodium Function(Ref ref);

Override configureRepositoryLocalStorageSodium({
  required Sodium sodium,
  required SecureKey encryptionKey,
  required FutureFn<String> baseDirFn,
  bool? clear,
}) =>
    hiveLocalStorageProvider.overrideWithProvider(
      Provider(
        (ref) => SodiumHiveLocalStorage(
          hive: ref.read(hiveProvider),
          sodium: sodium,
          encryptionKey: encryptionKey,
          baseDirFn: baseDirFn,
          clear: clear,
        ),
      ),
    );
