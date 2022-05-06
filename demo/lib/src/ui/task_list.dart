import 'package:flutter/material.dart';
import 'package:flutter_data_demo/main.data.dart';
import 'package:flutter_data_demo/src/ui/task_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskList extends ConsumerWidget {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  const TaskList({
    Key? key,
    required this.refreshIndicatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataState = ref.tasks.watchAll(syncLocal: false);
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: () => ref.tasks.findAll(syncLocal: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: dataState.model.length,
        itemBuilder: (context, index) => TaskListItem(
          task: dataState.model[index],
        ),
      ),
    );
  }
}
