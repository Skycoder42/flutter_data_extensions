import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

import 'example_remote_adapter.dart';

part 'example_model.g.dart';

@JsonSerializable()
@DataRepository([FirebaseDatabaseAdapter, ExampleRemoteAdapter])
class ExampleModel with DataModel<ExampleModel> {
  @override
  final String? id;

  final String title;
  final bool completed;

  ExampleModel({this.id, required this.title, this.completed = false});
}
