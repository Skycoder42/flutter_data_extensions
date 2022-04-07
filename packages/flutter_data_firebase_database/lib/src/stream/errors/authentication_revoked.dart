// coverage:ignore-file

/// An [Exception] indicating that a the credential used by the stream has
/// expired. This event is sent when the supplied auth parameter is no longer
/// valid.
class AuthenticationRevoked implements Exception {
  @override
  String toString() => 'The authentication token has expired or was revoked.';
}
