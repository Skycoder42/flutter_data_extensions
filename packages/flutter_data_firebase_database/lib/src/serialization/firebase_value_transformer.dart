import 'dart:convert';

import 'package:meta/meta.dart';

@internal
abstract class FirebaseValueTransformer {
  FirebaseValueTransformer._();

  static Object? transformAll(Object? rawData) {
    if (rawData is Map<String, dynamic>) {
      return <dynamic>[
        for (final entry in rawData.entries)
          if (entry.value is Map<String, dynamic>)
            <String, dynamic>{...entry.value, 'id': entry.key}
          else if (entry.value != null)
            entry.value,
      ];
    } else {
      return rawData;
    }
  }

  static Object? transformOne(Object? rawData, Object? id) {
    if (rawData is Map<String, dynamic>) {
      return <String, dynamic>{
        ...rawData,
        'id': id,
      };
    } else {
      return rawData;
    }
  }

  static Object? transformSaveCreate(Object? rawData, String requestBody) {
    if (rawData is Map<String, dynamic> &&
        rawData.keys.length == 1 &&
        rawData.keys.contains('name')) {
      final jsonRequest = json.decode(requestBody) as Map<String, dynamic>;
      return <String, dynamic>{
        ...jsonRequest,
        'id': rawData['name'],
      };
    } else {
      return rawData;
    }
  }

  static Object? transformSaveUpdate(Object? rawData, Object? id) {
    if (rawData is Map<String, dynamic>) {
      return <String, dynamic>{
        ...rawData,
        'id': id,
      };
    } else {
      return rawData;
    }
  }
}
