// ignore_for_file: prefer_mixin

import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

import 'test_adapter.dart';

part 'values_repository.g.dart';

@JsonSerializable()
@DataRepository([FirebaseDatabaseAdapter, TestAdapter])
class ValuesModel with DataModel<ValuesModel> {
  @override
  final String? id;
  final ServerTimestamp? serverTimestamp;
  final ServerIncrementable<double>? serverIncrementable;

  ValuesModel({
    this.id,
    this.serverTimestamp,
    this.serverIncrementable,
  });

  @override
  bool operator ==(Object other) {
    if (other is! ValuesModel) {
      return false;
    }

    return id == other.id &&
        serverTimestamp == other.serverTimestamp &&
        serverIncrementable == other.serverIncrementable;
  }

  @override
  int get hashCode =>
      id.hashCode ^ serverTimestamp.hashCode ^ serverIncrementable.hashCode;

  @override
  String toString() => 'TestModel($id, $serverTimestamp, $serverIncrementable)';
}
