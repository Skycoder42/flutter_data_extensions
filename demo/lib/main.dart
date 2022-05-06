import 'package:flutter/material.dart';
import 'package:flutter_data_demo/src/password/password_scope.dart';
import 'package:flutter_data_demo/src/setup/providers.dart';
import 'package:flutter_data_demo/src/ui/task_page.dart';
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
    child: const App(),
  ));
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Data Extensions Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ref.watch(initAllProvider).when(
            data: (_) => TaskPage(),
            error: _buildError,
            loading: _buildLoading,
          ),
    );
  }

  Widget _buildLoading() => const Scaffold(
        body: PasswordScope(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

  Widget _buildError(Object error, StackTrace? stackTrace) => Scaffold(
        body: SingleChildScrollView(
          child: Text(
            '$error\n$stackTrace',
            textAlign: TextAlign.center,
          ),
        ),
      );
}
