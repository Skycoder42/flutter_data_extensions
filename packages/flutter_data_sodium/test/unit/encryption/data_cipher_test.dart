import 'dart:typed_data';

import 'package:flutter_data_sodium/src/encryption/data_cipher.dart';
import 'package:flutter_data_sodium/src/encryption/encrypted_data.dart';
import 'package:flutter_data_sodium/src/key_management/key_info.dart';
import 'package:flutter_data_sodium/src/key_management/key_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockSodium extends Mock implements Sodium {}

class MockRandombytes extends Mock implements Randombytes {}

class MockCrypto extends Mock implements Crypto {}

class MockAead extends Mock implements Aead {}

class MockKeyManager extends Mock implements KeyManager {}

class FakeSecureKey extends Fake implements SecureKey {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(FakeSecureKey());
  });

  group('DataCipher', () {
    final mockSodium = MockSodium();
    final mockRandombytes = MockRandombytes();
    final mockCrypto = MockCrypto();
    final mockAead = MockAead();
    final mockKeyManager = MockKeyManager();

    late DataCipher sut;

    setUp(() {
      reset(mockSodium);
      reset(mockRandombytes);
      reset(mockCrypto);
      reset(mockAead);
      reset(mockKeyManager);

      when(() => mockSodium.randombytes).thenReturn(mockRandombytes);
      when(() => mockSodium.crypto).thenReturn(mockCrypto);
      when(() => mockCrypto.aead).thenReturn(mockAead);

      sut = DataCipher(
        sodium: mockSodium,
        keyManager: mockKeyManager,
      );
    });

    group('encrypt', () {
      const keyId = 42;
      final key = FakeSecureKey();
      const keyLength = 20;
      const nonceLength = 10;
      final nonce = Uint8List.fromList(List.filled(nonceLength, nonceLength));
      final cipherText = Uint8List.fromList(List.filled(5, 5));
      final mac = Uint8List.fromList(List.filled(15, 15));

      setUp(() {
        when(() => mockKeyManager.remoteKeyForType(any(), any()))
            .thenReturn(KeyInfo(keyId, key));
        when(() => mockRandombytes.buf(any())).thenReturn(nonce);
        when(() => mockAead.keyBytes).thenReturn(keyLength);
        when(() => mockAead.nonceBytes).thenReturn(nonceLength);
        when(
          () => mockAead.encryptDetached(
            message: any(named: 'message'),
            nonce: any(named: 'nonce'),
            key: any(named: 'key'),
            additionalData: any(named: 'additionalData'),
          ),
        ).thenReturn(DetachedCipherResult(cipherText: cipherText, mac: mac));
      });

      test('without id creates encrypted data without additional data', () {
        const testType = 'tests';
        const testData = {'name': 'stuff', 'value': 4.5};

        final encryptedData = sut.encrypt(testType, testData);

        expect(
          encryptedData,
          EncryptedData(
            id: null,
            cipherText: cipherText,
            mac: mac,
            nonce: nonce,
            hasAd: false,
            keyId: keyId,
          ),
        );

        verifyInOrder([
          () => mockAead.keyBytes,
          () => mockKeyManager.remoteKeyForType(testType, keyLength),
          () => mockAead.nonceBytes,
          () => mockRandombytes.buf(nonceLength),
          () => mockAead.encryptDetached(
                message:
                    '{"name":"stuff","value":4.5}'.toCharArray().unsignedView(),
                nonce: nonce,
                key: key,
              ),
        ]);
      });

      test('with id creates encrypted data with additional data', () {
        const testType = 'tests';
        const testId = 'test-id';
        const testData = {'id': testId, 'name': 'more', 'value': 5.4};

        final encryptedData = sut.encrypt(testType, testData);

        expect(
          encryptedData,
          EncryptedData(
            id: testId,
            cipherText: cipherText,
            mac: mac,
            nonce: nonce,
            hasAd: true,
            keyId: keyId,
          ),
        );

        verifyInOrder([
          () => mockAead.keyBytes,
          () => mockKeyManager.remoteKeyForType(testType, keyLength),
          () => mockAead.nonceBytes,
          () => mockRandombytes.buf(nonceLength),
          () => mockAead.encryptDetached(
                message:
                    '{"name":"more","value":5.4}'.toCharArray().unsignedView(),
                nonce: nonce,
                key: key,
                additionalData: '"$testId"'.toCharArray().unsignedView(),
              ),
        ]);
      });
    });

    group('decrypt', () {
      const keyId = 42;
      final key = FakeSecureKey();
      const keyLength = 20;
      const nonceLength = 10;
      final nonce = Uint8List.fromList(List.filled(nonceLength, nonceLength));
      final cipherText = Uint8List.fromList(List.filled(10, 10));
      final mac = Uint8List.fromList(List.filled(15, 15));

      setUp(() {
        when(() => mockKeyManager.remoteKeyForTypeAndId(any(), any(), any()))
            .thenReturn(key);
        when(() => mockAead.keyBytes).thenReturn(keyLength);
        when(() => mockAead.nonceBytes).thenReturn(nonceLength);
      });

      test('without additional data decrypts data without ad check', () {
        const testType = 'tests';
        const testId = 'test-id';
        final testData =
            '{"name":"anything","value":1.2}'.toCharArray().unsignedView();

        when(
          () => mockAead.decryptDetached(
            cipherText: any(named: 'cipherText'),
            mac: any(named: 'mac'),
            nonce: any(named: 'nonce'),
            key: any(named: 'key'),
            additionalData: any(named: 'additionalData'),
          ),
        ).thenReturn(testData);

        final dynamic data = sut.decrypt(
          testType,
          EncryptedData(
            id: testId,
            cipherText: cipherText,
            mac: mac,
            nonce: nonce,
            hasAd: false,
            keyId: keyId,
          ),
        );

        expect(data, {'id': testId, 'name': 'anything', 'value': 1.2});

        verifyInOrder([
          () => mockAead.keyBytes,
          () =>
              mockKeyManager.remoteKeyForTypeAndId(testType, keyId, keyLength),
          () => mockAead.decryptDetached(
                cipherText: cipherText,
                mac: mac,
                nonce: nonce,
                key: key,
              ),
        ]);
      });

      test('with additional data decrypts data with ad check', () {
        const testType = 'tests';
        const testId = 'test-id';
        final testData =
            '{"name":"extra","value":2.1}'.toCharArray().unsignedView();

        when(
          () => mockAead.decryptDetached(
            cipherText: any(named: 'cipherText'),
            mac: any(named: 'mac'),
            nonce: any(named: 'nonce'),
            key: any(named: 'key'),
            additionalData: any(named: 'additionalData'),
          ),
        ).thenReturn(testData);

        final dynamic data = sut.decrypt(
          testType,
          EncryptedData(
            id: testId,
            cipherText: cipherText,
            mac: mac,
            nonce: nonce,
            hasAd: true,
            keyId: keyId,
          ),
        );

        expect(data, {'id': testId, 'name': 'extra', 'value': 2.1});

        verifyInOrder([
          () => mockAead.keyBytes,
          () =>
              mockKeyManager.remoteKeyForTypeAndId(testType, keyId, keyLength),
          () => mockAead.decryptDetached(
                cipherText: cipherText,
                mac: mac,
                nonce: nonce,
                key: key,
                additionalData: '"$testId"'.toCharArray().unsignedView(),
              ),
        ]);
      });

      test('throws if ad is required but no id is given', () {
        const testType = 'tests';

        expect(
          () => sut.decrypt(
            testType,
            EncryptedData(
              id: null,
              cipherText: cipherText,
              mac: mac,
              nonce: nonce,
              hasAd: true,
              keyId: keyId,
            ),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
