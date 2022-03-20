// ignore_for_file: prefer_mixin

import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

import '../setup/account_setup.dart';
import '../setup/config_setup.dart';
import '../setup/database_setup.dart';

part 'test_repository.g.dart';

@JsonSerializable()
@DataRepository([FirebaseDatabaseAdapter, TestAdapter])
class TestModel with DataModel<TestModel> {
  @override
  final String? id;
  final String name;

  TestModel({this.id, required this.name});

  @override
  String toString() => 'TestModel($id, $name)';
}

mixin TestAdapter<T extends DataModel<T>> on FirebaseDatabaseAdapter<T> {
  @override
  String get baseUrl => Uri.https(
        ConfigSetup.databaseHost,
        read(DatabaseSetup.databasePathProvider),
      ).toString();

  @override
  String get idToken => read(AccountSetup.accountProvider).idToken;
}
