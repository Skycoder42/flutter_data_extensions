import 'dart:async';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';

mixin FirebaseDatabaseAdapter<T extends DataModel<T>> on RemoteAdapter<T> {
  String get idToken;

  @override
  FutureOr<Map<String, dynamic>> get defaultParams async => <String, dynamic>{
        ...await super.defaultParams,
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
    OnData<R>? actualOnSuccess;

    if (requestType == DataRequestType.findAll) {
      assert(onSuccess != null);
      actualOnSuccess = _findAllOnSuccess(onSuccess!);
    } else if (requestType == DataRequestType.save &&
        method == DataRequestMethod.POST) {
      assert(onSuccess != null);
      assert(body != null);

      actualOnSuccess = (data) {
        if (data is Map<String, dynamic> &&
            data.keys.length == 1 &&
            data.keys.contains('name')) {
          final jsonRequest = json.decode(body!) as Map<String, dynamic>;
          return onSuccess!(<String, dynamic>{
            ...jsonRequest,
            'id': data['name'],
          });
        } else {
          return onSuccess!(data);
        }
      };
    }

    return super.sendRequest(
      uri,
      method: method,
      headers: headers,
      omitDefaultParams: omitDefaultParams,
      requestType: requestType,
      key: key,
      body: body,
      onSuccess: actualOnSuccess ?? onSuccess,
      onError: onError,
    );
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
}
