// ignore_for_file: prefer_mixin

import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

import 'test_adapter.dart';

part 'test_repository.g.dart';

@JsonSerializable()
@DataRepository([FirebaseDatabaseAdapter, TestAdapter])
class TestModel with DataModel<TestModel> {
  @override
  final String? id;
  final String name;

  TestModel({this.id, required this.name});

  @override
  bool operator ==(Object other) {
    if (other is! TestModel) {
      return false;
    }

    return id == other.id && name == other.name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'TestModel($id, $name)';
}
