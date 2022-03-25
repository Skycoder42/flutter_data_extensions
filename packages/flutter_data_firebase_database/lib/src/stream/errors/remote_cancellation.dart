class RemoteCancellation implements Exception {
  final String reason;

  RemoteCancellation(this.reason);

  @override
  String toString() =>
      'The connection was cancelled by the server. Reason: $reason';
}
