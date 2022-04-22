import 'dart:typed_data';

import 'package:flutter_data_sodium/src/hive/sodium_hive_cipher.dart';
import 'package:flutter_data_sodium/src/hive/sodium_hive_local_storage.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockHive extends Mock implements HiveInterface {}

class MockSodium extends Mock implements Sodium {}

class MockRandombytes extends Mock implements Randombytes {}

class MockCrypto extends Mock implements Crypto {}

class MockSecretBox extends Mock implements SecretBox {}

class FakeSecureKey extends Fake implements SecureKey {
  @override
  final int length;

  FakeSecureKey(this.length);
}

void main() {
  group('SodiumHiveLocalStorage', () {
    const keyLength = 11;
    final fakeEncryptionKey = FakeSecureKey(keyLength);
    final mockHive = MockHive();
    final mockSodium = MockSodium();
    final mockRandombytes = MockRandombytes();
    final mockCrypto = MockCrypto();
    final mockSecretBox = MockSecretBox();

    setUp(() {
      reset(mockHive);
      reset(mockSodium);
      reset(mockRandombytes);
      reset(mockCrypto);
      reset(mockSecretBox);

      when(() => mockSodium.randombytes).thenReturn(mockRandombytes);
      when(() => mockSodium.crypto).thenReturn(mockCrypto);
      when(() => mockCrypto.secretBox).thenReturn(mockSecretBox);
      when(() => mockSecretBox.keyBytes).thenReturn(keyLength);
    });

    test('initializes HiveLocalStorage with SodiumHiveCipher', () {
      // ignore: prefer_function_declarations_over_variables
      final fakeBaseDirFn = () => '';
      final sut = SodiumHiveLocalStorage(
        hive: mockHive,
        sodium: mockSodium,
        encryptionKey: fakeEncryptionKey,
        baseDirFn: fakeBaseDirFn,
        clear: true,
      );

      expect(sut.hive, mockHive);
      expect(sut.baseDirFn, fakeBaseDirFn);
      expect(sut.clear, isTrue);

      expect(sut.encryptionCipher, isA<SodiumHiveCipher>());
      expect(sut.encryptionCipher, sut.sodiumHiveCipher);
      expect(sut.sodiumHiveCipher.sodium, mockSodium);
      expect(sut.sodiumHiveCipher.encryptionKey, fakeEncryptionKey);
    });

    test('encryptionCipher.generateIv uses sodium randombytes', () {
      const nonceBytes = 123;
      final testData = Uint8List.fromList(List.filled(10, 10));

      when(() => mockSecretBox.nonceBytes).thenReturn(nonceBytes);
      when(() => mockRandombytes.buf(any())).thenReturn(testData);

      final sut = SodiumHiveLocalStorage(
        hive: mockHive,
        sodium: mockSodium,
        encryptionKey: fakeEncryptionKey,
      );

      final cipher = sut.encryptionCipher;

      final iv = cipher.generateIv();
      expect(iv, testData);

      verifyInOrder([
        () => mockSecretBox.nonceBytes,
        () => mockRandombytes.buf(nonceBytes),
      ]);
    });
  });
}
