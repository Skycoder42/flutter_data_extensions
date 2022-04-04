import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';

import '../setup/account_setup.dart';
import '../setup/config_setup.dart';
import '../setup/database_setup.dart';

mixin TestAdapter<T extends DataModel<T>> on FirebaseDatabaseAdapter<T> {
  @override
  String get baseUrl => Uri.https(
        read(ConfigSetup.databaseHostProvider),
        read(DatabaseSetup.databasePathProvider),
      ).toString();

  @override
  String get idToken => read(AccountSetup.accountProvider).idToken;
}
