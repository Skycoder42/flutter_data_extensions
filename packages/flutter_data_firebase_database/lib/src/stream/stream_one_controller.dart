import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';

import '../firebase_database_adapter.dart';
import '../serialization/firebase_value_transformer.dart';
import 'database_event.dart';
import 'stream_controller_base.dart';

@internal
class StreamOneController<T extends DataModel<T>>
    extends StreamControllerBase<T, T?> {
  final String id;

  StreamOneController({
    required this.id,
    required Future<Stream<DatabaseEvent>> Function() createStream,
    required FirebaseDatabaseAdapter<T> adapter,
    bool autoRenew = true,
    UnsupportedEventCb? onUnsupportedEvent,
  }) : super(
          createStream: createStream,
          adapter: adapter,
          autoRenew: autoRenew,
          onUnsupportedEvent: onUnsupportedEvent,
        );

  @override
  Future<void> put(DatabaseEventData data) async {
    if (data.path != StreamControllerBase.rootPath) {
      onUnsupportedEvent?.call('put', data.path);
      return;
    }

    if (data.data != null) {
      final deserialized = adapter.deserialize(
        FirebaseValueTransformer.transformOne(data.data, id),
      );
      sink.add(deserialized.model);
    } else {
      await adapter.delete(id, remote: false);
      sink.add(null);
    }
  }

  @override
  void patch(DatabaseEventData data) =>
      onUnsupportedEvent?.call('patch', data.path);
}
