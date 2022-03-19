// ignore_for_file: prefer_mixin

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

import '../setup/account_setup.dart';

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
  String get baseUrl =>
      'https://flutter-data-extensions-default-rtdb.europe-west1.firebasedatabase.app/${read(AccountSetup.accountProvider).localId}';

  @override
  String get idToken => read(AccountSetup.accountProvider).idToken;
}
