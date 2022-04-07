import 'package:freezed_annotation/freezed_annotation.dart';

import 'format_mode.dart';
import 'timeout.dart';
import 'write_size_limit.dart';

part 'request_config.freezed.dart';

/// The standard request configuration for firebase requests. Allows to
/// configure standard realtime database parameters used by all firebase
/// requests.
@freezed
class RequestConfig with _$RequestConfig {
  const RequestConfig._();

  /// Default constructor.
  // ignore: sort_unnamed_constructors_first
  const factory RequestConfig({
    /// This is an advanced feature, designed to help you work with large
    /// datasets without needing to download everything. Set this to true to
    /// limit the depth of the data returned at a location. If the data at the
    /// location is a JSON primitive (string, number or boolean), its value will
    /// simply be returned. If the data snapshot at the location is a JSON
    /// object, the values for each key will be truncated to true.
    bool? shallow,

    /// The format mode to be used. See [FormatMode].
    FormatMode? format,

    /// The timeout for read requests. See [Timeout].
    Timeout? timeout,

    // The timeout estimation for write requests. See [WriteSizeLimit].
    WriteSizeLimit? writeSizeLimit,
  }) = _RequestConfig;

  /// Convert the request config into a map.
  ///
  /// As these parameters are typically used as request parameters, using this
  /// getter you can easily convert it. The returned map is unmodifiable.
  Map<String, String> get asParams => Map.unmodifiable(<String, String>{
        if (shallow != null) 'shallow': shallow!.toString(),
        if (format != null) 'format': format!.name,
        if (timeout != null) 'timeout': timeout!.toString(),
        if (writeSizeLimit != null) 'writeSizeLimit': writeSizeLimit!.name,
      });
}
