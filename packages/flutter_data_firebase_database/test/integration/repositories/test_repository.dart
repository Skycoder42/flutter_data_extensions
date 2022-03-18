// ignore_for_file: prefer_mixin

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

import '../global_setup.dart';

part 'test_repository.g.dart';

@JsonSerializable()
@DataRepository([FirebaseDatabaseAdapter, TestAdapter])
class TestModel with DataModel<TestModel> {
  @override
  final String? id;
  final String name;

  TestModel({this.id, required this.name});
}

mixin TestAdapter<T extends DataModel<T>> on FirebaseDatabaseAdapter<T> {
  static late final accountProvider = StateProvider<FirebaseAnonAccount>(
    (ref) => const FirebaseAnonAccount(idToken: '', localId: ''),
  );

  @override
  String get database => 'fir-test-35fc4';

  @override
  String get idToken => read(accountProvider).idToken;

  @override
  String get basePath => '/datasync/${read(accountProvider).localId}/';
}
