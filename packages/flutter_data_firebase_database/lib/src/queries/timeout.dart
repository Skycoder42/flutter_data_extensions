import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeout.freezed.dart';

/// Specifies timeout for read requests.
///
/// Use this to limit how long the read takes on the server side. If a read
/// request doesn't finish within the allotted time, it terminates with an HTTP
/// 400 error. This is particularly useful when you expect a small data transfer
/// and don't want to wait too long to fetch a potentially huge subtree. Actual
/// read time might vary based on data size and caching.
///
/// **Note:** The maximum timeout is 15 minutes.
@freezed
class Timeout with _$Timeout {
  const Timeout._();

  /// Creates a timeout with a milliseconds resolution for [value]
  @Assert('value > 0', 'value must be a positive integer')
  @Assert('value <= 900000', 'value must be at most 15 min (900000 ms)')
  const factory Timeout.ms(int value) = _TimeoutMs;

  /// Creates a timeout with a seconds resolution for [value]
  @Assert('value > 0', 'value must be a positive integer')
  @Assert('value <= 900', 'value must be at most 15 min (900 s)')
  const factory Timeout.s(int value) = _TimeoutS;

  /// Creates a timeout with a minutes resolution for [value]
  @Assert('value > 0', 'value must be a positive integer')
  @Assert('value <= 15', 'value must be at most 15 min')
  const factory Timeout.min(int value) = _TimeoutMin;

  /// The integer value of the timeout.
  ///
  /// Depending on the timeout, this can either be milliseconds, seconds or
  /// minutes.
  @override
  int get value;

  /// Creates a timeout from a [Duration] object.
  ///
  /// The limit of max. 15 minutes still applies for [duration]. The resulting
  /// timeout will be either ms, s or min, depending on whether the [duration]
  /// fits into each without a remainder. For durations with parts smaller then
  /// milliseconds, those parts get ignored.
  factory Timeout.fromDuration(Duration duration) {
    if (duration.inMilliseconds % 1000 != 0) {
      return Timeout.ms(duration.inMilliseconds);
    } else if (duration.inSeconds % 60 != 0) {
      return Timeout.s(duration.inSeconds);
    } else {
      return Timeout.min(duration.inMinutes);
    }
  }

  /// Converts the timeout to a [Duration] with the same time value.
  Duration get duration => when(
        ms: (value) => Duration(milliseconds: value),
        s: (value) => Duration(seconds: value),
        min: (value) => Duration(minutes: value),
      );

  @override
  String toString() => when(
        ms: (value) => '${value}ms',
        s: (value) => '${value}s',
        min: (value) => '${value}min',
      );
}
