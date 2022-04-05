import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:hive/hive.dart';

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

    Hive
      ..registerAdapter(const ServerTimestampHiveAdapter())
      ..registerAdapter(const ServerIncrementableHiveAdapter<double>());

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
