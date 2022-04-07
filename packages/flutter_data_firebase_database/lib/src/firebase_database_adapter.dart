import 'dart:async';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';

import 'queries/filter.dart';
import 'queries/request_config.dart';
import 'serialization/firebase_value_transformer.dart';
import 'stream/event_stream/database_event_stream.dart';
import 'stream/stream_all_controller.dart';
import 'stream/stream_controller_base.dart';
import 'stream/stream_one_controller.dart';
import 'transactions/transaction.dart';

mixin FirebaseDatabaseAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  String get idToken;

  RequestConfig? get defaultRequestConfig => null;

  Filter? get defaultQueryFilter => null;

  Stream<List<T>> streamAll({
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool syncLocal = false,
    bool autoRenew = true,
    UnsupportedEventCb? onUnsupportedEvent,
  }) =>
      StreamAllController<T>(
        createStream: () async {
          final actualParams = await defaultParams & params;
          return DatabaseEventStream(
            uri: baseUrl.asUri / urlForFindAll(actualParams) & actualParams,
            headers: await defaultHeaders & headers,
            client: httpClient,
          );
        },
        adapter: this,
        syncLocal: syncLocal,
        autoRenew: autoRenew,
        onUnsupportedEvent: onUnsupportedEvent,
      ).stream;

  Stream<T?> streamOne(
    String id, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool autoRenew = true,
    UnsupportedEventCb? onUnsupportedEvent,
  }) =>
      StreamOneController<T>(
        id: id,
        createStream: () async {
          final actualParams = await defaultParams & params;
          return DatabaseEventStream(
            uri: baseUrl.asUri / urlForFindOne(id, actualParams) & actualParams,
            headers: await defaultHeaders & headers,
            client: httpClient,
          );
        },
        adapter: this,
        autoRenew: autoRenew,
        onUnsupportedEvent: onUnsupportedEvent,
      ).stream;

  Future<T?> transaction(
    Object id,
    TransactionFn<T> transaction, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    OnDataError<T>? onBeginError,
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
        onBeginError: onBeginError,
        onCommitError: onCommitError,
      );

  @override
  @protected
  FutureOr<Map<String, dynamic>> get defaultParams async => <String, dynamic>{
        ...await super.defaultParams,
        ...?defaultRequestConfig?.asParams,
        'auth': idToken,
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

  @internal
  Future<Uri> generateGetUri(Object id, Map<String, dynamic>? params) async {
    final actualParams = await defaultParams & params;
    return baseUrl.asUri / urlForFindOne(id, actualParams) & actualParams;
  }

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
