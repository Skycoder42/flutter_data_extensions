// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:hive/hive.dart';

import '../repositories/test.data.dart';
import 'database_setup.dart';

mixin RepoSetup on DatabaseSetup {
  @override
  Future<void> setUpAll() async {
    await super.setUpAll();

    Hive
      ..registerAdapter(const ServerTimestampHiveAdapter())
      ..registerAdapter(const ServerIncrementableHiveAdapter<double>());

    await di.read(repositoryInitializerProvider(verbose: true).future);
  }
}
