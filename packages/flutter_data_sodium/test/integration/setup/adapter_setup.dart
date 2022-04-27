import 'dart:typed_data';

import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_sodium/flutter_data_sodium.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../repositories/test.data.dart';
import '../repositories/test_adapter.dart';
import '../repositories/test_repository.dart';

mixin AdapterSetup {
  late Repository<TestModel> testDataRepository;

  Override createLocalStorageOverride(
    Directory? testDir,
    Sodium sodium,
    Uint8List keyBytes,
  ) =>
      configureRepositoryLocalStorageSodium(
        sodium: (ref) => ref.watch(TestAdapter.sodiumProvider),
        encryptionKey: (ref) => SecureKey.fromList(
          ref.read(TestAdapter.sodiumProvider),
          keyBytes,
        ),
        baseDirFn: () => testDir?.path ?? '',
      );

  Future<void> initRepositories(ProviderContainer providerContainer) async {
    await providerContainer
        .read(repositoryInitializerProvider(verbose: true).future);

    testDataRepository = providerContainer.read(testModelsRepositoryProvider);
    addTearDown(() async {
      await testDataRepository.clear();
      testDataRepository.dispose();
    });
  }
}
