// coverage:ignore-file

/// Some unexpected errors can send a `cancel` event and terminate the
/// connection. The cause is described in the [reason] provided for this
/// [Exception]. Some potential causes are as follows:
///
/// 1. The Firebase Realtime Database Rules no longer allow a read at the
/// requested location. The [reason] description for this cause is "Permission
/// denied."
/// 2. A write triggered an event streamer that sent a large JSON tree that
/// exceeds our limit, 512MB. The [reason] for this cause is "The specified
/// payload is too large, please request a location with less data."
class RemoteCancellation implements Exception {
  /// The reason why the stream has been canceled.
  final String reason;

  // Default constructor.
  RemoteCancellation(this.reason);

  @override
  String toString() =>
      'The connection was cancelled by the server. Reason: $reason';
}
