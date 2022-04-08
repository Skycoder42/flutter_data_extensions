// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../firebase_database_adapter.dart';
import '../serialization/firebase_value_transformer.dart';
import 'etag_constants.dart';
import 'transaction_rejected.dart';

@internal
typedef CreateClientFn = http.Client Function();

@internal
class DataWithHeaders<T extends DataModel<T>> {
  final T? data;
  final Map<String, String> headers;

  const DataWithHeaders(this.data, this.headers);
}

@internal
class Transaction<T extends DataModel<T>> {
  final FirebaseDatabaseAdapter<T> adapter;
  final CreateClientFn httpClientFactory;

  const Transaction({
    required this.adapter,
    required this.httpClientFactory,
  });

  Future<T?> call(
    String id,
    TransactionFn<T> transaction, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    OnData<T>? onBeginSuccess,
    OnData<T>? onCommitSuccess,
    OnDataError<T>? onBeginError,
    OnDataError<T>? onCommitError,
  }) async {
    final response = await _findOneWithHeaders(
      id,
      params: params,
      headers: headers,
      onSuccess: onBeginSuccess,
      onError: onBeginError ?? _onBeginError<T>,
    );

    final eTag = _findETagHeader(response.headers);
    final updatedModel = await transaction(id, response.data);
    _validateTransaction(
      id: id,
      updatedModel: updatedModel,
      originalModel: response.data,
    );

    if (updatedModel != null) {
      return adapter.save(
        updatedModel,
        remote: true,
        params: params,
        headers: {
          ...?headers,
          ETagConstants.ifMatchHeaderName: eTag,
        },
        onSuccess: onCommitSuccess,
        onError: onCommitError ?? _createOnCommitError(id),
      );
    } else {
      await adapter.delete(
        id,
        remote: true,
        params: params,
        headers: {
          ...?headers,
          ETagConstants.ifMatchHeaderName: eTag,
        },
        onSuccess: onCommitSuccess,
        onError: onCommitError ?? _createOnCommitError(id),
      );
      return null;
    }
  }

  FutureOr<R?> _onBeginError<R>(DataException error) {
    if (error.statusCode == 404) {
      return null;
    }

    throw error;
  }

  OnDataError<R> _createOnCommitError<R>(String id) => (DataException error) {
        if (error.statusCode == 412) {
          throw TransactionRejected(id);
        }

        throw error;
      };

  Future<DataWithHeaders<T>> _findOneWithHeaders(
    String id, {
    required Map<String, dynamic>? params,
    required Map<String, String>? headers,
    required OnData<T>? onSuccess,
    required OnDataError<T> onError,
  }) async {
    final uri = await adapter.generateGetUri(id, params);
    final actualHeaders = await adapter.generateHeaders(headers) &
        ETagConstants.requestETagHeaders;

    DataException dataException;
    final httpClient = httpClientFactory();
    try {
      final response = await httpClient.get(uri, headers: actualHeaders);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        T? model;
        if (response.body.isNotEmpty) {
          final dynamic data = json.decode(response.body);
          model = adapter
              .deserialize(FirebaseValueTransformer.transformOne(data, id))
              .model;
        }
        return DataWithHeaders<T>(
          await onSuccess?.call(model) ?? model,
          response.headers,
        );
      }

      dataException = DataException(
        response.body,
        statusCode: response.statusCode,
      );
    } catch (err, stack) {
      dataException = DataException(
        err,
        stackTrace: stack,
      );
    } finally {
      httpClient.close();
    }

    return DataWithHeaders<T>(
      await onError(dataException),
      const {},
    );
  }

  String _findETagHeader(Map<String, String> headers) {
    final eTagHeaderName = ETagConstants.eTagHeaderName.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == eTagHeaderName) {
        return entry.value;
      }
    }

    return ETagConstants.nullETag;
  }

  void _validateTransaction({
    required String id,
    required T? updatedModel,
    required T? originalModel,
  }) {
    if (updatedModel == null) {
      return;
    }

    if (updatedModel.id != id) {
      throw TransactionInvalid.invalidId(id);
    }

    if (originalModel != null) {
      updatedModel.was(originalModel);
    }
  }
}
