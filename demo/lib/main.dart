import 'package:flutter/material.dart';
import 'package:flutter_data_demo/main.data.dart';
import 'package:flutter_data_demo/src/models/task.dart';
import 'package:flutter_data_demo/src/password/password_scope.dart';
import 'package:flutter_data_demo/src/setup/providers.dart';
import 'package:flutter_data_sodium/flutter_data_sodium.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  runApp(ProviderScope(
    overrides: [
      configureRepositoryLocalStorageSodium(
        sodium: (ref) => ref.watch(sodiumProvider),
        encryptionKey: (ref) => ref.watch(localEncryptionKeyProvider),
        baseDirFn: () =>
            getApplicationSupportDirectory().then((dir) => dir.path),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Data Extensions Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ref.watch(initAllProvider).when(
            data: (_) =>
                const MyHomePage(title: 'Flutter Data Extensions Demo'),
            error: (error, stackTrace) => Scaffold(
              body: SingleChildScrollView(
                child: Text(
                  '$error\n$stackTrace',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            loading: () => const Scaffold(
              body: PasswordScope(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final data = ref.tasks.watchAll(syncLocal: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: data.model.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(data.model[index].title),
          subtitle: Text(data.model[index].id ?? ''),
          trailing: Checkbox(
            value: data.model[index].completed,
            onChanged: null,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTask,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createNewTask() {
    ref.tasks.save(Task(title: 'New Task'));
  }
}
