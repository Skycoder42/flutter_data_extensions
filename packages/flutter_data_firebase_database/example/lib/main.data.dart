// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering, top_level_function_literal_block

import 'package:flutter_data/flutter_data.dart';

import 'package:flutter_data_firebase_database_example/src/example_model.dart';

// ignore: prefer_function_declarations_over_variables
ConfigureRepositoryLocalStorage configureRepositoryLocalStorage =
    ({FutureFn<String>? baseDirFn, List<int>? encryptionKey, bool? clear}) {
  return hiveLocalStorageProvider
      .overrideWithProvider(Provider((ref) => HiveLocalStorage(
            hive: ref.read(hiveProvider),
            baseDirFn: baseDirFn,
            encryptionKey: encryptionKey,
            clear: clear,
          )));
};

// ignore: prefer_function_declarations_over_variables
RepositoryInitializerProvider repositoryInitializerProvider =
    ({bool? remote, bool? verbose}) {
  return _repositoryInitializerProviderFamily(
      RepositoryInitializerArgs(remote, verbose));
};

final repositoryProviders = <String, Provider<Repository<DataModel>>>{
  'exampleModels': exampleModelsRepositoryProvider
};

final _repositoryInitializerProviderFamily =
    FutureProvider.family<RepositoryInitializer, RepositoryInitializerArgs>(
        (ref, args) async {
  final adapters = <String, RemoteAdapter>{
    'exampleModels': ref.watch(exampleModelsRemoteAdapterProvider)
  };
  final remotes = <String, bool>{'exampleModels': true};

  await ref.watch(graphNotifierProvider).initialize();

  final _repoMap = {
    for (final type in repositoryProviders.keys)
      type: ref.watch(repositoryProviders[type]!)
  };

  for (final type in _repoMap.keys) {
    final repository = _repoMap[type]!;
    repository.dispose();
    await repository.initialize(
      remote: args.remote ?? remotes[type],
      verbose: args.verbose,
      adapters: adapters,
    );
  }

  ref.onDispose(() {
    for (final repository in _repoMap.values) {
      repository.dispose();
    }
  });

  return RepositoryInitializer();
});
