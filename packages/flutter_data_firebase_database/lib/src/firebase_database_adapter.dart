import 'dart:async';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';

import 'queries/filter.dart';
import 'queries/request_config.dart';
import 'serialization/firebase_value_transformer.dart';
import 'stream/event_stream/database_event_stream.dart';
import 'stream/stream_all_controller.dart';

class TransactionFailureException implements Exception {}

class RawResponse {
  final int statusCode;
  final Object? data;
  final Map<String, String> headers;

  const RawResponse(this.statusCode, this.data, this.headers);
}

typedef TransactionFn<T extends DataModel<T>> = FutureOr<T?> Function(T? data);

mixin FirebaseDatabaseAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  String get idToken;

  RequestConfig? get defaultRequestConfig => null;

  Filter? get defaultQueryFilter => null;

  Stream<List<T>> streamAll({
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool? syncLocal,
    bool autoRenew = true,
    UnsupportedEventCb? onUnsupportedEvent,
    OnDataError<List<T>>? onError,
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
        syncLocal: syncLocal ?? false,
        autoRenew: autoRenew,
        onUnsupportedEvent: onUnsupportedEvent,
      ).stream;

  Stream<T?> streamOne(
    String id, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    OnDataError<T?>? onError,
  }) =>
      const Stream.empty();

  // Future<T?> transaction(
  //   Object id,
  //   TransactionFn<T> transaction, {
  //   Map<String, dynamic>? params,
  //   Map<String, String>? headers,
  //   OnDataError<T?>? onError,
  // }) async {
  //   final actualParams = await defaultParams & params;
  //   // final actualHeaders =
  //   //     await defaultHeaders & headers & ETagConstants.requestETagHeaders;

  //   final rawResponse = await _sendRawRequest(
  //     baseUrl.asUri / urlForFindOne(id, actualParams) & actualParams,
  //     method: methodForFindOne(id, actualParams),
  //     headers: headers,
  //     onError: onError,
  //   );

  //   if (rawResponse == null) {
  //     throw UnimplementedError(); // TODO
  //   }

  //   if (rawResponse.statusCode != 200) {
  //     throw UnimplementedError(); // TODO
  //   }

  //   final eTag = rawResponse.headers[ETagConstants.eTagHeaderName] ??
  //       ETagConstants.nullETag;
  //   final model = deserialize(rawResponse.data).model;

  //   final updatedModel = await transaction(model);
  //   if (updatedModel != null) {
  //     await save(
  //       updatedModel,
  //       remote: true,
  //       headers: {ETagConstants.ifMatchHeaderName: eTag},
  //       onError: onError ?? onTransactionError,
  //       // TODO params, headers, ...
  //     );
  //   } else {
  //     await delete(
  //       id,
  //       remote: true,
  //       headers: {ETagConstants.ifMatchHeaderName: eTag},
  //       onError: onError ?? onTransactionError,
  //       // TODO params, headers, ...
  //     );
  //   }

  //   return updatedModel;
  // }

  // FutureOr<T?> onTransactionError(DataException error) {
  //   if (error.statusCode == 412) {
  //     throw TransactionFailureException();
  //   }
  //   return onError(error);
  // }

  @override
  FutureOr<Map<String, dynamic>> get defaultParams async => <String, dynamic>{
        ...await super.defaultParams,
        ...?defaultRequestConfig?.asParams,
        'auth': idToken,
      };

  @override
  String urlForFindAll(Map<String, dynamic> params) =>
      '${super.urlForFindAll(params)}.json';

  @override
  String urlForFindOne(dynamic id, Map<String, dynamic> params) =>
      '${super.urlForFindOne(id, params)}.json';

  @override
  String urlForSave(dynamic id, Map<String, dynamic> params) =>
      '${super.urlForSave(id, params)}.json';

  @override
  DataRequestMethod methodForSave(dynamic id, Map<String, dynamic> params) =>
      id != null ? DataRequestMethod.PUT : DataRequestMethod.POST;

  @override
  String urlForDelete(dynamic id, Map<String, dynamic> params) =>
      '${super.urlForDelete(id, params)}.json';

  @override
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
        actualOnSuccess = _findAllOnSuccess(onSuccess!);
        break;
      case DataRequestType.findOne:
        assert(onSuccess != null);
        actualUri = _uriWithDefaultQuery(uri);
        actualOnSuccess = _findOneOnSuccess(onSuccess!, uri);
        break;
      case DataRequestType.save:
        assert(onSuccess != null);
        assert(body != null);
        if (method == DataRequestMethod.POST) {
          actualOnSuccess = _savePostOnSuccess(onSuccess!, body!);
        } else {
          actualBody = _savePutOrPatchBody(body!);
          actualOnSuccess = _savePutOrPatchOnSuccess(onSuccess!, uri);
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

  Uri _uriWithDefaultQuery(Uri uri) {
    if (!uri.queryParameters.containsKey(Filter.orderByKey)) {
      final filter = defaultQueryFilter;
      if (filter != null) {
        return uri & filter;
      }
    }

    return uri;
  }

  OnData<R> _findAllOnSuccess<R>(OnData<R> onSuccess) =>
      (rawData) => onSuccess(FirebaseValueTransformer.transformAll(rawData));

  OnData<R> _findOneOnSuccess<R>(OnData<R> onSuccess, Uri uri) =>
      (rawData) => onSuccess(
            FirebaseValueTransformer.transformOne(rawData, _idFromUrl(uri)),
          );

  OnData<R> _savePostOnSuccess<R>(OnData<R> onSuccess, String requestBody) =>
      (rawData) => onSuccess(
            FirebaseValueTransformer.transformCreated(rawData, requestBody),
          );

  OnData<R> _savePutOrPatchOnSuccess<R>(OnData<R> onSuccess, Uri uri) =>
      (rawData) => onSuccess(
            FirebaseValueTransformer.transformOne(
              rawData,
              _idFromUrl(uri),
            ),
          );

  String _savePutOrPatchBody(String body) {
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

  // Future<RawResponse?> _sendRawRequest(
  //   Uri uri, {
  //   DataRequestMethod method = DataRequestMethod.GET,
  //   Map<String, String>? headers,
  //   String? body,
  //   OnDataError<void>? onError,
  // }) async {
  //   http.Response? response;
  //   Object? data;
  //   Object? error;
  //   StackTrace? stackTrace;

  //   try {
  //     final request = http.Request(method.name, uri);
  //     request.headers.addAll(headers ?? const {});
  //     if (body != null) {
  //       request.body = body;
  //     }
  //     final stream = await httpClient.send(request);
  //     response = await http.Response.fromStream(stream);
  //   } catch (err, stack) {
  //     error = err;
  //     stackTrace = stack;
  //   } finally {
  //     httpClient.close();
  //   }

  //   final code = response?.statusCode;
  //   final responseHeaders = response?.headers ?? const {};
  //   try {
  //     if (response?.body.isNotEmpty ?? false) {
  //       data = json.decode(response!.body);
  //     }
  //   } on FormatException catch (e) {
  //     error = e;
  //   }

  //   if (error == null && code != null && code >= 200 && code < 300) {
  //     return RawResponse(code, data, responseHeaders);
  //   } else if (error != null) {
  //     final e = DataException(
  //       error,
  //       stackTrace: stackTrace,
  //       statusCode: code,
  //     );
  //     await (onError ?? this.onError).call(e);
  //     return null;
  //   } else {
  //     return RawResponse(
  //       code ?? 400,
  //       data,
  //       responseHeaders,
  //     );
  //   }
  // }
}
