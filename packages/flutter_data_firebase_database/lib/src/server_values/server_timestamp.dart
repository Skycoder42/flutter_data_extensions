import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server_timestamp.freezed.dart';

/// A virtual timestamp that can either be a [DateTime] or a server set value.
///
/// If you want to use a server timestamp for a database entry, you should use
/// this class instead of [DateTime]. It can be either set to a date time,
/// allowing you to set an actual time, or to the server timestamp, which
/// is a placeholder that will be replaced by the server time upon being
/// stored.
@freezed
class ServerTimestamp with _$ServerTimestamp {
  static const _serverValueJson = {'.sv': 'timestamp'};

  const ServerTimestamp._();

  /// Creates a timestamp placeholder that will be set to an actual [DateTime]
  /// upon being stored on the server.
  // ignore: sort_unnamed_constructors_first
  const factory ServerTimestamp() = _Server;

  /// Creates a timestamp from a [DateTime] [value]. Should be a UTC date time
  /// but works with date time objects in any timezone.
  const factory ServerTimestamp.value(DateTime value) = _Value;

  /// @nodoc
  factory ServerTimestamp.fromJson(dynamic json) {
    if (json is! int) {
      throw ArgumentError.value(
        json,
        'json',
        'Cannot deserialize a server timestamp placeholder',
      );
    }

    return ServerTimestamp.value(
      DateTime.fromMillisecondsSinceEpoch(json, isUtc: true),
    );
  }

  /// @nodoc
  dynamic toJson() => when(
        () => _serverValueJson,
        value: (value) => value.millisecondsSinceEpoch,
      );

  /// Returns the date time value of the timestamp.
  ///
  /// If used on a [ServerTimestamp.new], it will throw an error. Otherwise
  /// the date time value is returned.
  ///
  /// **Note:** Timestamps returned from the database server are always actual
  /// date time values and can be safely deconstructed. Only those explicitly
  /// created as server timestamps can throw.
  DateTime get dateTime => when(
        () => throw UnsupportedError(
          'cannot call dateTime on a server timestamp',
        ),
        value: (value) => value,
      );
}

class ServerTimestampHiveAdapter implements TypeAdapter<ServerTimestamp> {
  static const _serverId = 1;
  static const _valueId = 2;

  static const defaultTypeId = 71;

  @override
  final int typeId;

  const ServerTimestampHiveAdapter([this.typeId = defaultTypeId]);

  @override
  ServerTimestamp read(BinaryReader reader) {
    switch (reader.readByte()) {
      case _serverId:
        return const ServerTimestamp();
      case _valueId:
        return ServerTimestamp.value(reader.read() as DateTime);
      default:
        throw StateError('Unexpected server timestamp subtype!');
    }
  }

  @override
  void write(BinaryWriter writer, ServerTimestamp obj) {
    obj.when(
      () => writer.writeByte(_serverId),
      value: (value) => writer
        ..writeByte(_valueId)
        ..write(value),
    );
  }
}
