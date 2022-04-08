// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleModel _$ExampleModelFromJson(Map<String, dynamic> json) => ExampleModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$ExampleModelToJson(ExampleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'completed': instance.completed,
    };

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, non_constant_identifier_names

mixin $ExampleModelLocalAdapter on LocalAdapter<ExampleModel> {
  @override
  Map<String, Map<String, Object?>> relationshipsFor([ExampleModel? model]) =>
      {};

  @override
  ExampleModel deserialize(map) {
    for (final key in relationshipsFor().keys) {
      map[key] = {
        '_': [map[key], !map.containsKey(key)],
      };
    }
    return _$ExampleModelFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model) => _$ExampleModelToJson(model);
}

// ignore: must_be_immutable
class $ExampleModelHiveLocalAdapter = HiveLocalAdapter<ExampleModel>
    with $ExampleModelLocalAdapter;

class $ExampleModelRemoteAdapter = RemoteAdapter<ExampleModel>
    with
        FirebaseDatabaseAdapter<ExampleModel>,
        ExampleRemoteAdapter<ExampleModel>;

//

final exampleModelsRemoteAdapterProvider =
    Provider<RemoteAdapter<ExampleModel>>((ref) => $ExampleModelRemoteAdapter(
        $ExampleModelHiveLocalAdapter(ref.read),
        exampleModelProvider,
        exampleModelsProvider));

final exampleModelsRepositoryProvider = Provider<Repository<ExampleModel>>(
    (ref) => Repository<ExampleModel>(ref.read));

final _exampleModelProvider = StateNotifierProvider.autoDispose.family<
    DataStateNotifier<ExampleModel?>,
    DataState<ExampleModel?>,
    WatchArgs<ExampleModel>>((ref, args) {
  final adapter = ref.watch(exampleModelsRemoteAdapterProvider);
  final notifier =
      adapter.strategies.watchersOne[args.watcher] ?? adapter.watchOneNotifier;
  return notifier(args.id!,
      remote: args.remote,
      params: args.params,
      headers: args.headers,
      alsoWatch: args.alsoWatch,
      finder: args.finder);
});

AutoDisposeStateNotifierProvider<DataStateNotifier<ExampleModel?>,
        DataState<ExampleModel?>>
    exampleModelProvider(Object? id,
        {bool? remote,
        Map<String, dynamic>? params,
        Map<String, String>? headers,
        AlsoWatch<ExampleModel>? alsoWatch,
        String? finder,
        String? watcher}) {
  return _exampleModelProvider(WatchArgs(
      id: id,
      remote: remote,
      params: params,
      headers: headers,
      alsoWatch: alsoWatch,
      finder: finder,
      watcher: watcher));
}

final _exampleModelsProvider = StateNotifierProvider.autoDispose.family<
    DataStateNotifier<List<ExampleModel>>,
    DataState<List<ExampleModel>>,
    WatchArgs<ExampleModel>>((ref, args) {
  final adapter = ref.watch(exampleModelsRemoteAdapterProvider);
  final notifier =
      adapter.strategies.watchersAll[args.watcher] ?? adapter.watchAllNotifier;
  return notifier(
      remote: args.remote,
      params: args.params,
      headers: args.headers,
      syncLocal: args.syncLocal,
      finder: args.finder);
});

AutoDisposeStateNotifierProvider<DataStateNotifier<List<ExampleModel>>,
        DataState<List<ExampleModel>>>
    exampleModelsProvider(
        {bool? remote,
        Map<String, dynamic>? params,
        Map<String, String>? headers,
        bool? syncLocal,
        String? finder,
        String? watcher}) {
  return _exampleModelsProvider(WatchArgs(
      remote: remote,
      params: params,
      headers: headers,
      syncLocal: syncLocal,
      finder: finder,
      watcher: watcher));
}

extension ExampleModelDataX on ExampleModel {
  /// Initializes "fresh" models (i.e. manually instantiated) to use
  /// [save], [delete] and so on.
  ///
  /// Can be obtained via `ref.read`, `container.read`
  ExampleModel init(Reader read, {bool save = true}) {
    final repository = internalLocatorFn(exampleModelsRepositoryProvider, read);
    final updatedModel =
        repository.remoteAdapter.initializeModel(this, save: save);
    return save ? updatedModel : this;
  }
}

extension ExampleModelDataRepositoryX on Repository<ExampleModel> {
  FirebaseDatabaseAdapter<ExampleModel> get firebaseDatabaseAdapter =>
      remoteAdapter as FirebaseDatabaseAdapter<ExampleModel>;
  ExampleRemoteAdapter<ExampleModel> get exampleRemoteAdapter =>
      remoteAdapter as ExampleRemoteAdapter<ExampleModel>;
}
