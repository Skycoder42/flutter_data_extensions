// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering, top_level_function_literal_block

import 'package:flutter_data/flutter_data.dart';

import 'test_repository.dart';
import 'values_repository.dart';

// ignore: prefer_function_declarations_over_variables
ConfigureRepositoryLocalStorage configureRepositoryLocalStorage = ({
  FutureFn<String>? baseDirFn,
  List<int>? encryptionKey,
  bool? clear,
}) =>
    hiveLocalStorageProvider.overrideWithProvider(
      Provider(
        (_) => HiveLocalStorage(
          baseDirFn: baseDirFn,
          encryptionKey: encryptionKey,
          clear: clear,
        ),
      ),
    );

// ignore: prefer_function_declarations_over_variables
RepositoryInitializerProvider repositoryInitializerProvider =
    ({bool? remote, bool? verbose}) => _repositoryInitializerProviderFamily(
          RepositoryInitializerArgs(remote, verbose),
        );

final repositoryProviders = <String, Provider<Repository<DataModel>>>{
  'testModels': testModelsRepositoryProvider,
  'valuesModels': valuesModelsRepositoryProvider,
};

final _repositoryInitializerProviderFamily =
    FutureProvider.family<RepositoryInitializer, RepositoryInitializerArgs>(
        (ref, args) async {
  final adapters = <String, RemoteAdapter>{
    'testModels': ref.watch(testModelsRemoteAdapterProvider),
    'valuesModels': ref.watch(valuesModelsRemoteAdapterProvider),
  };
  final remotes = <String, bool>{
    'testModels': true,
    'valuesModels': true,
  };

  await ref.watch(graphNotifierProvider).initialize();

  final _repoMap = {
    for (final type in repositoryProviders.keys)
      type: ref.watch(repositoryProviders[type]!)
  };

  for (final type in _repoMap.keys) {
    final repository = _repoMap[type]!..dispose();
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
