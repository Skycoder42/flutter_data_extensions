import 'package:flutter_data/flutter_data.dart';

class TestDataModel extends DataModel<TestDataModel> {
  @override
  final String? id;
  final int? data;

  TestDataModel({
    this.id,
    this.data,
  });

  @override
  bool operator ==(Object other) {
    if (other is! TestDataModel) {
      return false;
    }

    return id == other.id && data == other.data;
  }

  @override
  int get hashCode => id.hashCode ^ data.hashCode;

  @override
  String toString() => 'TestDataModel($id, $data)';
}
