import 'dart:typed_data';

import 'package:sodium/sodium.dart';
import 'package:uuid/uuid.dart';

typedef UuidGrngFn = Uint8List Function();

extension SodiumUuid on Sodium {
  static late final _uuids = Expando<Uuid>();

  static UuidGrngFn grng(Randombytes randombytes) => () => randombytes.buf(16);

  Uuid get uuid => _uuids[this] ??= Uuid(
        options: <String, dynamic>{
          'grng': grng(randombytes),
        },
      );
}
