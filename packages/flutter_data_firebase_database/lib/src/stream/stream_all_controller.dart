// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';

import '../firebase_database_adapter.dart';
import '../serialization/firebase_value_transformer.dart';
import 'database_event.dart';
import 'stream_controller_base.dart';

@internal
class StreamAllController<T extends DataModel<T>>
    extends StreamControllerBase<T, List<T>> {
  static final _subPathRegexp = RegExp(r'^\/([^\/]+)$');

  final bool syncLocal;

  List<T> _streamState = const [];

  StreamAllController({
    required Future<Stream<DatabaseEvent>> Function() createStream,
    required FirebaseDatabaseAdapter<T> adapter,
    this.syncLocal = false,
    bool autoRenew = true,
    UnsupportedEventCb? onUnsupportedEvent,
  }) : super(
          createStream: createStream,
          adapter: adapter,
          autoRenew: autoRenew,
          onUnsupportedEvent: onUnsupportedEvent,
        );

  @override
  Future<void> put(DatabaseEventData data) =>
      data.path == StreamControllerBase.rootPath ? _reset(data) : _update(data);

  Future<void> _reset(DatabaseEventData data) async {
    if (syncLocal) {
      await adapter.clear();
    }

    if (data.data != null) {
      final deserialized = adapter.deserialize(
        FirebaseValueTransformer.transformAll(data.data),
      );

      _replaceState(deserialized.models);
    } else {
      _replaceState(const []);
    }
  }

  Future<void> _update(DatabaseEventData data) async {
    final match = _subPathRegexp.firstMatch(data.path);
    if (match != null) {
      if (data.data != null) {
        final deserialized = adapter.deserialize(
          FirebaseValueTransformer.transformOne(data.data, match[1]),
        );
        _updateState(deserialized.model!);
      } else {
        final id = match[1]!;
        await adapter.delete(id, remote: false);
        _removeState(id);
      }
    } else {
      onUnsupportedEvent?.call('put', data.path);
    }
  }

  @override
  Future<void> patch(DatabaseEventData data) async {
    if (data.path != StreamControllerBase.rootPath) {
      onUnsupportedEvent?.call('patch', data.path);
      return;
    }

    final eventData = data.data;
    var deletedIds = const <String>[];
    if (eventData is Map<String, dynamic>) {
      deletedIds = eventData.entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList(growable: false);
      for (final id in deletedIds) {
        await adapter.delete(id, remote: false);
      }
    }

    final deserialized = adapter.deserialize(
      FirebaseValueTransformer.transformAll(data.data),
    );

    _patchState(deserialized.models, deletedIds);
  }

  void _replaceState(List<T> newState) {
    _streamState = List.unmodifiable(newState);
    sink.add(_streamState);
  }

  void _updateState(T data) {
    var added = false;
    T dataAsAdded() {
      added = true;
      return data;
    }

    _streamState = List.unmodifiable(<T>[
      for (final value in _streamState)
        if (!added && value.id == data.id) dataAsAdded() else value,
      if (!added) data,
    ]);

    sink.add(_streamState);
  }

  void _removeState(String id) {
    _streamState = List.unmodifiable(<T>[
      for (final value in _streamState)
        if (value.id != id) value,
    ]);

    sink.add(_streamState);
  }

  void _patchState(List<T> modified, List<String> deleted) {
    final modifiedPairs = {
      for (final value in modified) value.id: value,
    };

    _streamState = List.unmodifiable(<T>[
      for (final value in _streamState)
        if (modifiedPairs.containsKey(value.id))
          modifiedPairs.remove(value.id)!
        else if (!deleted.contains(value.id))
          value,
      ...modifiedPairs.values,
    ]);

    sink.add(_streamState);
  }
}
