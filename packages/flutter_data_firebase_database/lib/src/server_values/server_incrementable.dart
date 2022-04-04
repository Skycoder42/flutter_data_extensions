import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server_incrementable.freezed.dart';

@freezed
class ServerIncrementable<T extends num> with _$ServerIncrementable<T> {
  const ServerIncrementable._();

  // ignore: sort_unnamed_constructors_first
  const factory ServerIncrementable(T increment) = _Server<T>;

  const factory ServerIncrementable.value(T value) = _Value<T>;

  factory ServerIncrementable.fromJson(dynamic json) {
    if (json is! T) {
      throw ArgumentError.value(
        json,
        'json',
        'Cannot deserialize a server incrementable placeholder',
      );
    }

    return ServerIncrementable.value(json);
  }

  dynamic toJson() => when(
        (increment) => {
          '.sv': {'increment': increment},
        },
        value: (value) => value,
      );

  T get value => when(
        (_) => throw UnsupportedError(
          'cannot call value on a server increment',
        ),
        value: (value) => value,
      );
}

class ServerIncrementableHiveAdapter<T extends num>
    implements TypeAdapter<ServerIncrementable<T>> {
  static const _serverId = 1;
  static const _valueId = 2;

  static const defaultTypeId = 72;

  @override
  final int typeId;

  const ServerIncrementableHiveAdapter([this.typeId = defaultTypeId]);

  @override
  ServerIncrementable<T> read(BinaryReader reader) {
    switch (reader.readByte()) {
      case _serverId:
        return ServerIncrementable(reader.read() as T);
      case _valueId:
        return ServerIncrementable.value(reader.read() as T);
      default:
        throw StateError('Unexpected server incrementable subtype!');
    }
  }

  @override
  void write(BinaryWriter writer, ServerIncrementable<T> obj) {
    obj.when(
      (increment) => writer
        ..writeByte(_serverId)
        ..write(increment),
      value: (value) => writer
        ..writeByte(_valueId)
        ..write(value),
    );
  }
}
