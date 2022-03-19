import 'dart:io';

import 'package:flutter_data/flutter_data.dart';
import 'package:test/test.dart';

import 'repositories/test.data.dart';
import 'repositories/test_repository.dart';
import 'setup/account_setup.dart';
import 'setup/database_setup.dart';
import 'setup/setup.dart';

void main() {
  final di = ProviderContainer(
    overrides: [
      configureRepositoryLocalStorage(
        baseDirFn: () =>
            Directory.systemTemp.createTemp().then((dir) => dir.path),
      ),
    ],
  );

  Setup.setup([
    AccountSetup(di),
    DatabaseSetup(di),
  ]);

  test('first test', () async {
    await di.read(repositoryInitializerProvider(verbose: true).future);

    final testRepo = di.read(testModelsRepositoryProvider);

    final savedData = await testRepo.save(TestModel(name: 'Hello World'));
    print(savedData);
    final data = await testRepo.findOne(savedData.id!);
    print(data);
    final allData = await testRepo.findAll();
    print(allData);

    final updated =
        await TestModel(id: data!.id, name: 'Hello Tree').was(data).save();
    print(updated);

    await updated.delete();
  });
}
