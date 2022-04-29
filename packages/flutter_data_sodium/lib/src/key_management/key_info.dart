// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sodium/sodium.dart';

part 'key_info.freezed.dart';

/// Provides a [keyId] and a [secureKey] pair.
///
/// Used by [KeyManager.remoteKeyForType] to provide both, the current key
/// and the id required for decryption.
@freezed
class KeyInfo with _$KeyInfo {
  /// Default constructor.
  const factory KeyInfo(
    /// The id of the [secureKey].
    ///
    /// Can be used in conjunction with [KeyManager.remoteKeyForTypeAndId] to
    /// re-obtain the same key.
    int keyId,

    /// The actual key.
    SecureKey secureKey,
  ) = _KeyInfo;
}
