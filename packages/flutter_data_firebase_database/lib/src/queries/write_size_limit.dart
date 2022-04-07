/// The Realtime Database estimates the size of each write request and aborts
/// requests that will take longer than the target time.
enum WriteSizeLimit {
  /// target=1s
  tiny,

  /// target=10s
  small,

  /// target=30s
  medium,

  /// target=60s
  large,

  /// Exceptionally large writes (with up to 256MB payload) are allowed
  unlimited,
}
