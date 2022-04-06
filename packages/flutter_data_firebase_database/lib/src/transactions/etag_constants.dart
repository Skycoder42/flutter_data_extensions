// coverage:ignore-file

import 'package:meta/meta.dart';

@internal
abstract class ETagConstants {
  const ETagConstants._(); // coverage:ignore-line

  static const requestETagHeaders = {'X-Firebase-ETag': 'true'};

  static const eTagHeaderName = 'ETag';

  static const ifMatchHeaderName = 'if-match';

  static const statusCodeETagMismatch = 412;

  static const nullETag = 'null_etag';
}
