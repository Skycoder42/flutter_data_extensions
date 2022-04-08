import 'dart:io';

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database_example/main.data.dart';
import 'package:flutter_data_firebase_database_example/src/example_model.dart';
import 'package:flutter_data_firebase_database_example/src/example_remote_adapter.dart';

Future<void> main(List<String> arguments) async {
  final ref = ProviderContainer(
    overrides: [
      configureRepositoryLocalStorage(
        baseDirFn: () =>
            Directory.systemTemp.createTemp().then((dir) => dir.path),
      ),
    ],
  );

  ref.read(baseUrlProvider.notifier).state = arguments[0];
  ref.read(idTokenProvider.notifier).state =
      arguments.length >= 2 ? arguments[1] : null;

  await ref.read(repositoryInitializerProvider().future);

  final repository = ref.read(exampleModelsRepositoryProvider);

  print('Find all:');
  print(await repository.findAll(syncLocal: true));

  print('Find transaction:');
  print(await repository.firebaseDatabaseAdapter.transaction(
    'test',
    (id, data) => ExampleModel(id: id, title: 'new example'),
  ));

  print('Stream all:');
  repository.firebaseDatabaseAdapter.streamAll().listen(print);
}
