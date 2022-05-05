import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:flutter_data_sodium/flutter_data_sodium.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../setup/application_adapter.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
@DataRepository([
  FirebaseDatabaseAdapter,
  SodiumRemoteAdapter,
  ApplicationAdapter,
])
class Task with DataModel<Task>, _$Task {
  Task._();

  factory Task({
    String? id,
    required String title,
    @Default(false) bool completed,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
