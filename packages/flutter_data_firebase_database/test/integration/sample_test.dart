// ignore_for_file: avoid_print

import 'package:flutter_data/flutter_data.dart';
import 'package:test/test.dart';

import 'repositories/test.data.dart';
import 'repositories/test_repository.dart';
import 'setup/account_setup.dart';
import 'setup/config_setup.dart';
import 'setup/database_setup.dart';
import 'setup/di_setup.dart';
import 'setup/setup.dart';

class _SampleTestSetup extends Setup
    with DiSetup, ConfigSetup, AccountSetup, DatabaseSetup {}

void main() {
  final setup = _SampleTestSetup()..call();

  test('first test', () async {
    await setup.di.read(repositoryInitializerProvider(verbose: true).future);

    final testRepo = setup.di.read(testModelsRepositoryProvider);

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
