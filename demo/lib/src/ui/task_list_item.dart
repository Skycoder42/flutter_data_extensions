import 'package:flutter/material.dart';
import 'package:flutter_data_demo/src/models/task.dart';
import 'package:flutter_data/flutter_data.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(task.title),
        subtitle: Text(task.id ?? 'saving...'),
        trailing: Checkbox(
          value: task.completed,
          onChanged: _toggleCompleted,
        ),
      );

  Future<void> _toggleCompleted(value) async {
    await task.copyWith(completed: value).was(task).save();
  }
}
