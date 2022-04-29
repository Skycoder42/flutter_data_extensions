import 'dart:typed_data';

import 'package:sodium/sodium.dart';
import 'package:uuid/uuid.dart';

/// A callback that will generate 16 bytes of random data.
typedef UuidGrngFn = Uint8List Function();

/// An extension on [Sodium] that provides a [Uuid] instances that uses
/// [Randombytes] to securely generate truly random UUIDs.
extension SodiumUuid on Sodium {
  static late final _uuids = Expando<Uuid>();

  /// Creates a callback that returns 16 bytes of random data from a
  /// [randombytes] instance.
  static UuidGrngFn grng(Randombytes randombytes) => () => randombytes.buf(16);

  /// Returns a [Uuid] instance that uses [Randombytes] as random generator to
  /// generate random UUIDs.
  Uuid get uuid => _uuids[this] ??= Uuid(
        options: <String, dynamic>{
          'grng': grng(randombytes),
        },
      );
}
