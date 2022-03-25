import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_event.freezed.dart';
part 'database_event.g.dart';

@freezed
class DatabaseEventData with _$DatabaseEventData {
  const factory DatabaseEventData({
    required String path,
    required Object? data,
  }) = _DatabaseEventData;

  factory DatabaseEventData.fromJson(Map<String, dynamic> json) =>
      _$DatabaseEventDataFromJson(json);

  factory DatabaseEventData.fromRawJson(String rawJson) =>
      DatabaseEventData.fromJson(
        json.decode(rawJson) as Map<String, dynamic>,
      );
}

@freezed
class DatabaseEvent with _$DatabaseEvent {
  static const putEvent = 'put';
  static const patchEvent = 'patch';
  static const keepAliveEvent = 'keep-alive';
  static const cancelEvent = 'cancel';
  static const authRevokedEvent = 'auth_revoked';

  const factory DatabaseEvent.put(DatabaseEventData data) = _Put;
  const factory DatabaseEvent.patch(DatabaseEventData data) = _Patch;
  const factory DatabaseEvent.keepAlive() = _KeepAlive;
  const factory DatabaseEvent.cancel(String reason) = _Cancel;
  const factory DatabaseEvent.authRevoked() = _AuthRevoked;
}
