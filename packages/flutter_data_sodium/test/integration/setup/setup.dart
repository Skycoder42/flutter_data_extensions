import 'dart:typed_data';

import 'package:flutter_data/flutter_data.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../repositories/test_adapter.dart';
import '../server/server_controller.dart';
import 'adapter_setup.dart';
import 'sodium_setup_vm.dart' if (dart.library.js) 'sodium_setup_js.dart';
import 'test_key_manager.dart';

const _kIsWeb = identical(0, 0.0);

class Setup with SodiumSetup, KeyManagerSetup, AdapterSetup {
  late Directory? _testDir;

  late ProviderContainer providerContainer;
  late ServerController serverController;

  void call(Uint8List masterKeyBytes) {
    setUp(() async {
      _testDir = _kIsWeb ? null : await Directory.systemTemp.createTemp();

      serverController = ServerController();
      final sodium = await loadSodium();
      final keyManager = await loadKeyManager(sodium, masterKeyBytes);

      providerContainer = ProviderContainer(
        overrides: [
          TestAdapter.baseUrlProvider
              .overrideWithValue(await serverController.baseUrl),
          TestAdapter.sodiumProvider.overrideWithValue(sodium),
          TestAdapter.keyManagerProvider.overrideWithValue(keyManager),
          createLocalStorageOverride(_testDir, sodium, masterKeyBytes),
        ],
      );

      await initRepositories(providerContainer);
    });

    tearDown(() async {
      await providerContainer.read(hiveLocalStorageProvider).hive.close();
      providerContainer.dispose();

      await _testDir?.delete(recursive: true);
    });
  }
}
