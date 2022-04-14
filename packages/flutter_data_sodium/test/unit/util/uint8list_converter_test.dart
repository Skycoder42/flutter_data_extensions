import 'dart:typed_data';

import 'package:flutter_data_sodium/src/util/uint8list_converter.dart';
import 'package:test/test.dart';

void main() {
  group('Uint8ListConverter', () {
    final binaryData = Uint8List.fromList(List.generate(14, (index) => index));
    const base64Data = 'AAECAwQFBgcICQoLDA0=';

    const sut = Uint8ListConverter();

    test('toJson creates base64 encoded data', () {
      final result = sut.toJson(binaryData);
      expect(result, base64Data);
    });

    test('fromJson decodes base64 data', () {
      final result = sut.fromJson(base64Data);
      expect(result, binaryData);
    });
  });
}
