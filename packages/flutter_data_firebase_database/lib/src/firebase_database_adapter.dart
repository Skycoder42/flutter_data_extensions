import 'dart:async';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';

import 'queries/filter.dart';
import 'queries/request_config.dart';
import 'serialization/firebase_value_transformer.dart';
import 'stream/event_stream/database_event_stream.dart';
import 'stream/stream_all_controller.dart';
import 'stream/stream_one_controller.dart';
import 'transactions/transaction.dart';

/// A callback for handling unsupported realtime database events.
///
/// Can be used to log these events or to throw an exception to terminate the
/// connection.
typedef UnsupportedEventCb = void Function(String event, String? path);

/// The transaction function definition.
///
/// All transaction get either the [data] or null and must return data or null.
/// If data is returned, it's [DataModel.id] must be the same as the
/// transaction id. If this method throws, the transaction is aborted.
typedef TransactionFn<T extends DataModel<T>> = FutureOr<T?> Function(T? data);

/// A [RemoteAdapter] you can use to add the firebase realtime database as
/// backend for a repository.
///
/// This class provides all the internal logic enabling you to use a standard
/// flutter_data repository to connect with a firebase realtime database and
/// use it as remote storage backend for your local data. It also provides
/// some extra functionality, mainly streaming remote changes and remote
/// transactions.
mixin FirebaseDatabaseAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  /// The current idToken of the account you want to use.
  ///
  /// When using the [FirebaseDatabaseAdapter], this member must always be
  /// overridden. Typically, you should return the id token of the firebase
  /// account making the request. However, in case you want to access a public
  /// realtime database that does not require authentication, you can return
  /// `null` instead to send unauthenticated requests.
  String? get idToken;

  /// The default [RequestConfig] added to all requests.
  ///
  /// Contains general configuration parameters like read and write size limits.
  ///
  /// To overwrite these values on a per-request basis, simply pass a
  /// [RequestConfig.asParams] as params to the request you want to send:
  ///
  /// ```dart
  /// repository.findOne('id', params: RequestConfig(...));
  /// ```
  RequestConfig? get defaultRequestConfig => null;

  /// The default query filter to be added to all GET-requests.
  ///
  /// This includes [findAll], [findOne], [streamAll], [streamOne] and
  /// [transaction]. Such a global filter can be used to create a repository
  /// that only represents a specific subset of data on the server.
  ///
  /// You can overwrite the default filter by adding a filter to a request as
  /// params:
  ///
  /// ```dart
  /// repository.findOne('id', params: Filter...build());
  /// ```
  Filter? get defaultQueryFilter => null;

  /// Creates a stream to the remote server to receive continuous updates
  /// about all changes to the repository.
  ///
  /// Unlike [watchAll], which only fetches data once and then listens to the
  /// local repository for changes, this method instead creates a permanent
  /// connection to the remote server to get realtime changes of all
  /// modifications of the server.
  ///
  /// The stream itself will return the current state of the server, with each
  /// modification leading to a new copy of the old state with that mutation
  /// applied. In addition, all changes are also persisted locally.
  ///
  /// Typically, the stream stays alive until explicitly closed by the consumer.
  /// However, in some cases the server might encounter an error and decide to
  /// close the stream. In that case, a [RemoteCancellation] exception is thrown
  /// before the stream closes.
  ///
  /// The parameters [params], [headers] and [syncLocal] work the same way as
  /// for [findAll]. The [autoRenew] flag controls what happens if the stream
  /// is closed by the server because the auth token has expired. If set to
  /// `true` (the default), the stream will automatically be recreated with a
  /// new auth token. When disabled, is such cases a [AuthenticationRevoked]
  /// exception will be thrown.
  ///
  /// The final parameter, [onUnsupportedEvent] can be used to implement custom
  /// handling of server events that cannot be consumed by the stream. This can
  /// happen, if for example data deep in the tree is modified, as the stream
  /// cannot perform patches on properties of individual data models.
  // coverage:ignore-start
  Stream<List<T>> streamAll({
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool syncLocal = false,
    bool autoRenew = true,
    UnsupportedEventCb? onUnsupportedEvent,
  }) =>
      StreamAllController<T>(
        createStream: () async => DatabaseEventStream(
          uri: await generateGetAllUri(params),
          headers: await generateHeaders(headers),
          client: httpClient,
        ),
        adapter: this,
        syncLocal: syncLocal,
        autoRenew: autoRenew,
        onUnsupportedEvent: onUnsupportedEvent,
      ).stream;
  // coverage:ignore-end

  /// Creates a stream to the remote server to receive continuous updates
  /// about all changes on the data model identified by [id].
  ///
  /// Unlike [watchOne], which only fetches data once and then listens to the
  /// local repository for changes, this method instead creates a permanent
  /// connection to the remote server to get realtime changes of all
  /// modifications of the server.
  ///
  /// The stream itself will return the current state of the element, with each
  /// modification leading to a new event with the new version of the data
  /// model. In case of deletions, this means `null` get emitted. In addition,
  /// all changes are also persisted locally.
  ///
  /// Typically, the stream stays alive until explicitly closed by the consumer.
  /// However, in some cases the server might encounter an error and decide to
  /// close the stream. In that case, a [RemoteCancellation] exception is thrown
  /// before the stream closes.
  ///
  /// The parameters [params] and [headers] work the same way as for [findAll].
  /// The [autoRenew] flag controls what happens if the stream is closed by the
  /// server because the auth token has expired. If set to `true` (the default),
  /// the stream will automatically be recreated with a new auth token. When
  /// disabled, is such cases a [AuthenticationRevoked] exception will be
  /// thrown.
  ///
  /// The final parameter, [onUnsupportedEvent] can be used to implement custom
  /// handling of server events that cannot be consumed by the stream. This can
  /// happen, if for example data deep in the tree is modified, as the stream
  /// cannot perform patches on properties of individual data models.
  // coverage:ignore-start
  Stream<T?> streamOne(
    String id, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool autoRenew = true,
    UnsupportedEventCb? onUnsupportedEvent,
  }) =>
      StreamOneController<T>(
        id: id,
        createStream: () async => DatabaseEventStream(
          uri: await generateGetUri(id, params),
          headers: await generateHeaders(headers),
          client: httpClient,
        ),
        adapter: this,
        autoRenew: autoRenew,
        onUnsupportedEvent: onUnsupportedEvent,
      ).stream;
  // coverage:ignore-end

  /// Executes a remote [transaction] on the given [id].
  ///
  /// Calling this method will first download the current data for the given
  /// [id] from the server. That data is then passed to [transaction] to be
  /// processed. Once the transaction completes, the result of that method is
  /// then saved in the database under the same [id].
  ///
  /// Should the data on the server have been modified in between reading and
  /// writing it, a [TransactionRejected] exception will be thrown. In addition,
  /// the data returned by the [transaction] must be either `null` or have the
  /// same [DataModel.id] as [id]. Otherwise, a [TransactionInvalid] exception
  /// is thrown.
  ///
  /// The [params] and [headers] are simply forwarded to the internal calls to
  /// [findOne] and [save]/[delete]. The [onBeginSuccess] and [onBeginError]
  /// methods can optionally be specified to add customized data handling for
  /// the read request. In similar fashion, the [onCommitSuccess] and
  /// [onCommitError] are passed to the writing operation that commits the
  /// transaction.
  // coverage:ignore-start
  Future<T?> transaction(
    String id,
    TransactionFn<T> transaction, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    OnData<T>? onBeginSuccess,
    OnDataError<T>? onBeginError,
    OnData<T>? onCommitSuccess,
    OnDataError<T>? onCommitError,
  }) =>
      Transaction(
        adapter: this,
        httpClientFactory: () => httpClient,
      ).call(
        id,
        transaction,
        params: params,
        headers: headers,
        onBeginSuccess: onBeginSuccess,
        onBeginError: onBeginError,
        onCommitSuccess: onCommitSuccess,
        onCommitError: onCommitError,
      );
  // coverage:ignore-end

  @override
  @protected
  FutureOr<Map<String, dynamic>> get defaultParams async => <String, dynamic>{
        ...await super.defaultParams,
        ...?defaultRequestConfig,
        if (idToken != null) 'auth': idToken,
      };

  @override
  @protected
  String urlForFindAll(Map<String, dynamic> params) =>
      '${super.urlForFindAll(params)}.json';

  @override
  @protected
  String urlForFindOne(dynamic id, Map<String, dynamic> params) =>
      '${super.urlForFindOne(id, params)}.json';

  @override
  @protected
  String urlForSave(dynamic id, Map<String, dynamic> params) =>
      '${super.urlForSave(id, params)}.json';

  @override
  @protected
  DataRequestMethod methodForSave(dynamic id, Map<String, dynamic> params) =>
      id != null ? DataRequestMethod.PUT : DataRequestMethod.POST;

  @override
  @protected
  String urlForDelete(dynamic id, Map<String, dynamic> params) =>
      '${super.urlForDelete(id, params)}.json';

  @override
  @protected
  FutureOr<R?> sendRequest<R>(
    Uri uri, {
    DataRequestMethod method = DataRequestMethod.GET,
    Map<String, String>? headers,
    bool omitDefaultParams = false,
    DataRequestType requestType = DataRequestType.adhoc,
    String? key,
    String? body,
    OnData<R>? onSuccess,
    OnDataError<R>? onError,
  }) {
    Uri? actualUri;
    OnData<R>? actualOnSuccess;
    String? actualBody;

    switch (requestType) {
      case DataRequestType.findAll:
        assert(onSuccess != null);
        actualUri = _uriWithDefaultQuery(uri);
        actualOnSuccess = _transformAllOnSuccess(onSuccess!);
        break;
      case DataRequestType.findOne:
        assert(onSuccess != null);
        actualUri = _uriWithDefaultQuery(uri);
        actualOnSuccess = _transformOneOnSuccess(onSuccess!, uri);
        break;
      case DataRequestType.save:
        assert(onSuccess != null);
        assert(body != null);
        if (method == DataRequestMethod.POST) {
          actualOnSuccess = _transformPostOnSuccess(onSuccess!, body!);
        } else {
          actualBody = _bodyWithoutId(body!);
          actualOnSuccess = _transformOneOnSuccess(onSuccess!, uri);
        }
        break;
      case DataRequestType.delete:
      case DataRequestType.adhoc:
        break;
    }

    return super.sendRequest(
      actualUri ?? uri,
      method: method,
      headers: headers,
      omitDefaultParams: omitDefaultParams,
      requestType: requestType,
      key: key,
      body: actualBody ?? body,
      onSuccess: actualOnSuccess ?? onSuccess,
      onError: onError,
    );
  }

  /// @nodoc
  @internal
  Future<Uri> generateGetAllUri(Map<String, dynamic>? params) async {
    final actualParams = await defaultParams & params;
    return _uriWithDefaultQuery(
      baseUrl.asUri / urlForFindAll(actualParams) & actualParams,
    );
  }

  /// @nodoc
  @internal
  Future<Uri> generateGetUri(String id, Map<String, dynamic>? params) async {
    final actualParams = await defaultParams & params;
    return _uriWithDefaultQuery(
      baseUrl.asUri / urlForFindOne(id, actualParams) & actualParams,
    );
  }

  /// @nodoc
  @internal
  Future<Map<String, String>> generateHeaders(
    Map<String, String>? headers,
  ) async =>
      await defaultHeaders & headers;

  Uri _uriWithDefaultQuery(Uri uri) {
    if (!uri.queryParameters.containsKey(Filter.orderByKey)) {
      final filter = defaultQueryFilter;
      if (filter != null) {
        return uri & filter;
      }
    }

    return uri;
  }

  OnData<R> _transformAllOnSuccess<R>(OnData<R> onSuccess) =>
      (rawData) => onSuccess(FirebaseValueTransformer.transformAll(rawData));

  OnData<R> _transformOneOnSuccess<R>(OnData<R> onSuccess, Uri uri) =>
      (rawData) => onSuccess(
            FirebaseValueTransformer.transformOne(rawData, _idFromUrl(uri)),
          );

  OnData<R> _transformPostOnSuccess<R>(
    OnData<R> onSuccess,
    String requestBody,
  ) =>
      (rawData) => onSuccess(
            FirebaseValueTransformer.transformCreated(rawData, requestBody),
          );

  String _bodyWithoutId(String body) {
    final dynamic jsonData = json.decode(body);
    if (jsonData is Map<String, dynamic>) {
      jsonData.remove('id');
      return json.encode(jsonData);
    } else {
      return body;
    }
  }

  static late final _findOneUriIdRegExp = RegExp(r'\.json$');
  static String _idFromUrl(Uri uri) =>
      uri.pathSegments.last.replaceAll(_findOneUriIdRegExp, '');
}
