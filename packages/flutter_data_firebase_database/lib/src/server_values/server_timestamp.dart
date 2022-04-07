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
///
/// **Important:** To use the [ServerTimestamp], it must be registered with
/// hive. See [ServerTimestampHiveAdapter] for details on how to do that.
@freezed
class ServerTimestamp with _$ServerTimestamp {
  static const _serverValueJson = {'.sv': 'timestamp'};

  const ServerTimestamp._();

  /// Creates a timestamp placeholder that will be set to an actual [DateTime]
  /// upon being stored on the server.
  const factory ServerTimestamp.server() = _Server;

  /// Creates a timestamp from a [DateTime] [value].
  ///
  /// Must be a DateTime in the UTC time zone, as time zone information is not
  /// stored in firebase. You can use [DateTime.toUtc] to convert a date time
  /// to UTC.
  @Assert('value.isUtc', 'Must be a UTC-DateTime')
  factory ServerTimestamp.value(
    /// The date time value, in UTC.
    DateTime value,
  ) = _Value;

  /// @nodoc
  factory ServerTimestamp.fromJson(dynamic json) {
    if (json is int) {
      return ServerTimestamp.value(
        DateTime.fromMillisecondsSinceEpoch(json, isUtc: true),
      );
    } else if (json == _serverValueJson) {
      return const ServerTimestamp.server();
    }

    throw ArgumentError.value(
      json,
      'json',
      'Invalid JSON value - '
          'must be an integer or a server timestamp placeholder',
    );
  }

  /// @nodoc
  dynamic toJson() => when(
        server: () => _serverValueJson,
        value: (value) => value.millisecondsSinceEpoch,
      );

  /// Returns the date time value of the timestamp.
  ///
  /// If used on a [ServerTimestamp.server], it will throw an error. Otherwise
  /// the date time value is returned. It will always be a UTC date time.
  ///
  /// **Note:** Timestamps returned from the database server are always actual
  /// date time values and can be safely deconstructed. Only those explicitly
  /// locally as server timestamps can throw.
  DateTime get dateTime => when(
        server: () => throw UnsupportedError(
          'cannot call dateTime on a server timestamp',
        ),
        value: (value) => value,
      );
}

/// A hive [TypeAdapter] for [ServerTimestamp]s.
///
/// This is needed when working with [ServerTimestamp] as otherwise the local
/// hive adapter will not be able to store the timestamps. To register it,
/// simply add the adapter to the hive local storage before initializing the
/// repositories:
///
/// ```dart
/// // register adapter
/// ref.read(hiveLocalStorageProvider).hive
///   .registerAdapter(const ServerTimestampHiveAdapter())
///
/// // continue with repository initialization
/// await ref.read(repositoryInitializerProvider().future);
/// ```
class ServerTimestampHiveAdapter implements TypeAdapter<ServerTimestamp> {
  static const _serverId = 1;
  static const _valueId = 2;

  /// The default type id for the [ServerTimestampHiveAdapter]
  static const defaultTypeId = 71;

  @override
  final int typeId;

  /// Default constructor
  ///
  /// Creates a new [ServerTimestampHiveAdapter]. By default, the
  /// [defaultTypeId] is used as [typeId], but it can be overwritten.
  const ServerTimestampHiveAdapter([this.typeId = defaultTypeId]);

  @override
  ServerTimestamp read(BinaryReader reader) {
    switch (reader.readByte()) {
      case _serverId:
        return const ServerTimestamp.server();
      case _valueId:
        return ServerTimestamp.value(reader.read() as DateTime);
      default:
        throw StateError('Unexpected server timestamp subtype!');
    }
  }

  @override
  void write(BinaryWriter writer, ServerTimestamp obj) {
    obj.when(
      server: () => writer.writeByte(_serverId),
      value: (value) => writer
        ..writeByte(_valueId)
        ..write(value),
    );
  }
}
