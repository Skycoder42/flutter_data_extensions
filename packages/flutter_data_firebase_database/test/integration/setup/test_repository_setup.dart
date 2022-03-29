import 'package:flutter_data/flutter_data.dart';

import '../repositories/test_repository.dart';
import 'account_setup.dart';
import 'config_setup.dart';
import 'database_setup.dart';
import 'di_setup.dart';
import 'repo_setup.dart';
import 'setup.dart';

class TestRepositorySetup extends Setup
    with DiSetup, ConfigSetup, AccountSetup, DatabaseSetup, RepoSetup {
  late Repository<TestModel> repository;

  @override
  Future<void> setUpAll() async {
    await super.setUpAll();

    repository = di.read(testModelsRepositoryProvider);
  }

  @override
  Future<void> tearDownAll() async {
    try {
      repository.dispose();
    } finally {
      await super.tearDownAll();
    }
  }
}
