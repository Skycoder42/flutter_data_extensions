import 'dart:io';

import 'package:flutter_data/flutter_data.dart';
import 'package:test/test.dart';

import 'global_setup.dart';
import 'repositories/test.data.dart';
import 'repositories/test_repository.dart';

void main() {
  final accountRef = setupFirebase();

  test('first test', () async {
    final di = ProviderContainer(
      overrides: [
        configureRepositoryLocalStorage(
          baseDirFn: () =>
              Directory.systemTemp.createTemp().then((dir) => dir.path),
        ),
      ],
    );

    await di.read(repositoryInitializerProvider(verbose: true).future);

    di.read(TestAdapter.accountProvider.state).state = accountRef.account;

    final testRepo = di.read(testModelsRepositoryProvider);

    final savedData = await testRepo.save(TestModel(name: 'Hello World'));
    print(savedData);
    final data = await testRepo.findOne(savedData.id!);
    print(data);
  });
}
