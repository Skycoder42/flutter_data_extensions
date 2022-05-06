import 'package:flutter/material.dart';
import 'package:flutter_data_demo/src/models/task.dart';
import 'package:flutter_data_demo/src/ui/task_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskPage extends ConsumerWidget {
  final _refreshKey = GlobalKey<RefreshIndicatorState>(
    debugLabel: 'KittenPage.refresh',
  );

  TaskPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Data Extensions Demo'),
        actions: [
          IconButton(
            onPressed: () => _refreshKey.currentState?.show(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _clearAll(ref),
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNew(ref),
        child: const Icon(Icons.add),
      ),
      body: TaskList(
        refreshIndicatorKey: _refreshKey,
      ),
    );
  }

  Future<void> _clearAll(WidgetRef ref) async {
    final tasksRepo = ref.read(tasksRepositoryProvider);
    final tasks = await tasksRepo.findAll(remote: false);
    for (final t in tasks) {
      tasksRepo.delete(t);
    }
  }

  Future<void> _addNew(WidgetRef ref) {
    return ref
        .read(tasksRepositoryProvider)
        .save(Task(title: 'New Task - ${DateTime.now()}'));
  }
}
