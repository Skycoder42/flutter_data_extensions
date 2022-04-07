import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server_incrementable.freezed.dart';

/// A virtual incrementable value that can either be just a plain numeric value
/// or an increment.
///
/// Using the server incrementable allows you to store numbers in the realtime
/// database with the option to increment them. You can either set it to a
/// value, in which case that value will simply be stored on the server.
/// Alternatively, you can create an increment, which will increment the server
/// value by the given amount and return the new value upon being stored.
///
/// **Important:** To use the [ServerIncrementable], it must be registered with
/// hive. See [ServerIncrementableHiveAdapter] for details on how to do that.
@freezed
class ServerIncrementable<T extends num> with _$ServerIncrementable<T> {
  const ServerIncrementable._();

  /// Creates an increment placeholder that will increment the current server
  /// value by the given [increment]. If the value was `null`, it will simply
  /// be set to that value.
  const factory ServerIncrementable.increment(
    /// The value by which the server data will be incremented.
    T increment,
  ) = _Increment<T>;

  /// Creates a server incrementable from a [value].
  ///
  /// This will overwrite the current server value by the given [value].
  const factory ServerIncrementable.value(
    /// The new value to be stored on the server
    T value,
  ) = _Value<T>;

  /// @nodoc
  factory ServerIncrementable.fromJson(dynamic json) {
    if (json is T) {
      return ServerIncrementable.value(json);
    } else {
      final sv = _getFromSingularMap<Map<String, dynamic>>(json, '.sv');
      if (sv != null) {
        final increment = _getFromSingularMap<T>(sv, 'increment');
        if (increment != null) {
          return ServerIncrementable.increment(increment);
        }
      }

      throw ArgumentError.value(
        json,
        'json',
        'Invalid JSON value - must be a $T or server incrementable placeholder',
      );
    }
  }

  /// @nodoc
  dynamic toJson() => when(
        increment: (increment) => {
          '.sv': {'increment': increment},
        },
        value: (value) => value,
      );

  /// Returns the current value of the incrementable
  ///
  /// If used on a [ServerIncrementable.increment], it will throw an error.
  /// Otherwise the numeric value is returned.
  ///
  /// **Note:** Server incrementables returned from the database server are
  /// always actual number values and can be safely deconstructed. Only those
  /// locally created as server increment can throw.
  T get value => when(
        increment: (_) => throw UnsupportedError(
          'cannot call value on a server increment',
        ),
        value: (value) => value,
      );

  static T? _getFromSingularMap<T extends Object>(dynamic json, String key) {
    if (json is Map<String, dynamic> &&
        json.length == 1 &&
        json.containsKey(key)) {
      final dynamic data = json[key];
      if (data is T) {
        return data;
      }
    }

    return null;
  }
}

/// A hive [TypeAdapter] for [ServerIncrementable]s.
///
/// This is needed when working with [ServerIncrementable] as otherwise the
/// local hive adapter will not be able to store the timestamps. To register it,
/// simply add the adapter to the hive local storage before initializing the
/// repositories:
///
/// ```dart
/// // register adapter
/// ref.read(hiveLocalStorageProvider).hive
///   .registerAdapter(const ServerIncrementableHiveAdapter<T>())
///
/// // continue with repository initialization
/// await ref.read(repositoryInitializerProvider().future);
/// ```
class ServerIncrementableHiveAdapter<T extends num>
    implements TypeAdapter<ServerIncrementable<T>> {
  static const _serverId = 1;
  static const _valueId = 2;

  /// The default type id for the [ServerIncrementableHiveAdapter]
  static const defaultTypeId = 72;

  @override
  final int typeId;

  /// Default constructor
  ///
  /// Creates a new [ServerIncrementableHiveAdapter]. By default, the
  /// [defaultTypeId] is used as [typeId], but it can be overwritten.
  const ServerIncrementableHiveAdapter([this.typeId = defaultTypeId]);

  @override
  ServerIncrementable<T> read(BinaryReader reader) {
    switch (reader.readByte()) {
      case _serverId:
        return ServerIncrementable.increment(reader.read() as T);
      case _valueId:
        return ServerIncrementable.value(reader.read() as T);
      default:
        throw StateError('Unexpected server incrementable subtype!');
    }
  }

  @override
  void write(BinaryWriter writer, ServerIncrementable<T> obj) {
    obj.when(
      increment: (increment) => writer
        ..writeByte(_serverId)
        ..write(increment),
      value: (value) => writer
        ..writeByte(_valueId)
        ..write(value),
    );
  }
}
