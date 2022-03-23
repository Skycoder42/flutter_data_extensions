import 'package:freezed_annotation/freezed_annotation.dart';

import 'format_mode.dart';
import 'timeout.dart';
import 'write_size_limit.dart';

part 'request_config.freezed.dart';

@freezed
class RequestConfig with _$RequestConfig {
  const RequestConfig._();

  // ignore: sort_unnamed_constructors_first
  const factory RequestConfig({
    bool? shallow,
    FormatMode? format,
    Timeout? timeout,
    WriteSizeLimit? writeSizeLimit,
  }) = _RequestConfig;

  Map<String, String> get asParams => {
        if (shallow != null) 'shallow': shallow!.toString(),
        if (format != null) 'format': format!.name,
        if (timeout != null) 'timeout': timeout!.toString(),
        if (writeSizeLimit != null) 'writeSizeLimit': writeSizeLimit!.name,
      };
}
