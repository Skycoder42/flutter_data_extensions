abstract class ETagConstants {
  const ETagConstants._(); // coverage:ignore-line

  static const requestETagHeaders = {'X-Firebase-ETag': 'true'};

  static const eTagHeaderName = 'ETag';

  static const ifMatchHeaderName = 'if-match';

  /// 412 Precondition Failed
  ///
  /// The request's specified ETag value in the if-match header did not match
  /// the server's value.
  static const statusCodeETagMismatch = 412;

  /// ETag that indicates a null value at the server.
  static const nullETag = 'null_etag';
}
