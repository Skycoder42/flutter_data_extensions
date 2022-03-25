class AuthenticationRevoked implements Exception {
  @override
  String toString() => 'The authentication token has expired or was revoked.';
}
