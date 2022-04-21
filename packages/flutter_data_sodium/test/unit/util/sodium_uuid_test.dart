import 'dart:typed_data';

import 'package:flutter_data_sodium/src/util/sodium_uuid.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockSodium extends Mock implements Sodium {}

class MockRandombytes extends Mock implements Randombytes {}

void main() {
  group('SodiumUuid', () {
    final mockSodium = MockSodium();
    final mockRandombytes = MockRandombytes();

    setUp(() {
      reset(mockSodium);
      reset(mockRandombytes);

      when(() => mockSodium.randombytes).thenReturn(mockRandombytes);
    });

    test('grng returns function that generates random 16 byte blocks', () {
      final testData = Uint8List.fromList(List.generate(10, (index) => index));

      when(() => mockRandombytes.buf(any())).thenReturn(testData);

      final grng = SodiumUuid.grng(mockRandombytes);

      expect(grng(), testData);

      verify(() => mockRandombytes.buf(16));
    });

    test('uuid creates a Uuid instance with randombytes randomness', () {
      when(() => mockRandombytes.buf(any())).thenAnswer(
        (i) => Uint8List.fromList(
          List.filled(i.positionalArguments[0] as int, 42),
        ),
      );

      final id = mockSodium.uuid.v4();

      expect(id, '2a2a2a2a-2a2a-4a2a-aa2a-2a2a2a2a2a2a');

      verify(() => mockRandombytes.buf(16));
    });
  });
}
