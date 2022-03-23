import 'dart:async';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';

import 'queries/filter.dart';
import 'queries/request_config.dart';

mixin FirebaseDatabaseAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  String get idToken;

  RequestConfig? get defaultRequestConfig => null;

  Filter? get defaultQueryFilter => null;

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

  OnData<R> _findAllOnSuccess<R>(OnData<R> onSuccess) => (rawData) {
        if (rawData is Map<String, dynamic>) {
          return onSuccess(<dynamic>[
            for (final entry in rawData.entries)
              if (entry.value is Map<String, dynamic>)
                <String, dynamic>{...entry.value, 'id': entry.key}
              else
                entry.value,
          ]);
        } else {
          return onSuccess(rawData);
        }
      };

  OnData<R> _findOneOnSuccess<R>(OnData<R> onSuccess, Uri uri) => (rawData) {
        if (rawData is Map<String, dynamic>) {
          return onSuccess(<String, dynamic>{
            ...rawData,
            'id': _idFromUrl(uri),
          });
        } else {
          return onSuccess(rawData);
        }
      };

  OnData<R> _savePostOnSuccess<R>(OnData<R> onSuccess, String requestBody) =>
      (rawData) {
        if (rawData is Map<String, dynamic> &&
            rawData.keys.length == 1 &&
            rawData.keys.contains('name')) {
          final jsonRequest = json.decode(requestBody) as Map<String, dynamic>;
          return onSuccess(<String, dynamic>{
            ...jsonRequest,
            'id': rawData['name'],
          });
        } else {
          return onSuccess(rawData);
        }
      };

  String _savePutOrPatchBody(String body) {
    final dynamic jsonData = json.decode(body);
    if (jsonData is Map<String, dynamic>) {
      jsonData.remove('id');
      return json.encode(jsonData);
    } else {
      return body;
    }
  }

  OnData<R> _savePutOrPatchOnSuccess<R>(OnData<R> onSuccess, Uri uri) =>
      (rawData) {
        if (rawData is Map<String, dynamic>) {
          return onSuccess(<String, dynamic>{
            ...rawData,
            'id': _idFromUrl(uri),
          });
        } else {
          return onSuccess(rawData);
        }
      };

  static late final _findOneUriIdRegExp = RegExp(r'\.json$');
  String _idFromUrl(Uri uri) =>
      uri.pathSegments.last.replaceAll(_findOneUriIdRegExp, '');
}
