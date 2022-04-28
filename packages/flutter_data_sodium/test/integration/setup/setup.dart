import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../repositories/test_adapter.dart';
import 'adapter_setup.dart';
import 'http_setup.dart';
import 'sodium_setup_vm.dart' if (dart.library.js) 'sodium_setup_js.dart';
import 'test_key_manager.dart';

const _kIsWeb = identical(0, 0.0);

class Setup with HttpSetup, SodiumSetup, KeyManagerSetup, AdapterSetup {
  late final Sodium _sodium;
  late Directory? _testDir;

  late ProviderContainer providerContainer;

  @override
  bool keepDataOnce = false;

  void call(Uint8List masterKeyBytes, [Clock? clock]) {
    setUpAll(() async {
      _sodium = await loadSodium();
    });

    setUp(() async {
      if (keepDataOnce) {
        // ignore: avoid_print
        print('> using data of previous test');
        keepDataOnce = false;
      } else {
        _testDir = _kIsWeb ? null : await Directory.systemTemp.createTemp();
      }

      final keyManager = await loadKeyManager(_sodium, masterKeyBytes, clock);

      providerContainer = ProviderContainer(
        overrides: [
          TestAdapter.sodiumProvider.overrideWithValue(_sodium),
          TestAdapter.keyManagerProvider.overrideWithValue(keyManager),
          createHttpOverride(),
          createLocalStorageOverride(_testDir, _sodium, masterKeyBytes),
        ],
      );

      await initRepositories(providerContainer);
    });

    tearDown(() async {
      await providerContainer.read(hiveLocalStorageProvider).hive.close();
      providerContainer.dispose();

      if (keepDataOnce) {
        // ignore: avoid_print
        print('> keeping data for next test');
      } else {
        await _testDir?.delete(recursive: true);
      }
    });
  }
}
