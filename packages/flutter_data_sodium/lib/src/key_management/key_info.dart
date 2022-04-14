// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sodium/sodium.dart';

part 'key_info.freezed.dart';

@freezed
class KeyInfo with _$KeyInfo {
  const factory KeyInfo(
    int keyId,
    SecureKey secureKey,
  ) = _KeyInfo;
}
