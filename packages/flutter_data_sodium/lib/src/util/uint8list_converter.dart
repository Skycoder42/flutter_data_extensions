import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// @nodoc
@internal
class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  /// @nodoc
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) => base64.decode(json);

  @override
  String toJson(Uint8List object) => base64.encode(object);
}
