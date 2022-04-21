import 'dart:typed_data';

import 'package:flutter_data_sodium/src/hive/sodium_hive_cipher.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockSodium extends Mock implements Sodium {}

class MockRandombytes extends Mock implements Randombytes {}

class MockCrypto extends Mock implements Crypto {}

class MockSecretBox extends Mock implements SecretBox {}

class MockGenericHash extends Mock implements GenericHash {}

class FakeSecureKey extends Fake implements SecureKey {
  final Uint8List data;

  FakeSecureKey(this.data);

  @override
  int get length => data.length;

  @override
  T runUnlockedSync<T>(SecureCallbackFn<T> callback, {bool writable = false}) =>
      callback(data);
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(FakeSecureKey(Uint8List(0)));
  });

  group('SodiumHiveCipher', () {
    final mockSodium = MockSodium();
    final mockRandombytes = MockRandombytes();
    final mockCrypto = MockCrypto();
    final mockSecretBox = MockSecretBox();
    final mockGenericHash = MockGenericHash();

    setUp(() {
      reset(mockSodium);
      reset(mockRandombytes);
      reset(mockCrypto);
      reset(mockSecretBox);
      reset(mockGenericHash);

      when(() => mockSodium.randombytes).thenReturn(mockRandombytes);
      when(() => mockSodium.crypto).thenReturn(mockCrypto);
      when(() => mockCrypto.secretBox).thenReturn(mockSecretBox);
      when(() => mockCrypto.genericHash).thenReturn(mockGenericHash);
    });

    group('static', () {
      test('keyBytes returns secret box keybytes', () {
        const keyBytes = 11;
        when(() => mockSecretBox.keyBytes).thenReturn(keyBytes);

        final result = SodiumHiveCipher.keyBytes(mockSodium);
        expect(result, keyBytes);

        verify(() => mockSecretBox.keyBytes);
      });
    });

    group('constructor', () {
      test('asserts if key length is not as expected', () {
        const keyBytes = 20;
        final fakeEncryptionKey = FakeSecureKey(Uint8List(keyBytes + 1));

        when(() => mockSecretBox.keyBytes).thenReturn(keyBytes);

        expect(
          () => SodiumHiveCipher(
            sodium: mockSodium,
            encryptionKey: fakeEncryptionKey,
          ),
          throwsA(isA<AssertionError>()),
        );

        verify(() => mockSecretBox.keyBytes).called(2);
      });
    });

    group('instance', () {
      const keyBytes = 20;
      final fakeEncryptionKey = FakeSecureKey(
        Uint8List.fromList(List.filled(keyBytes, 10)),
      );

      late SodiumHiveCipher sut;

      setUp(() {
        when(() => mockSecretBox.keyBytes).thenReturn(keyBytes);

        sut = SodiumHiveCipher(
          sodium: mockSodium,
          encryptionKey: fakeEncryptionKey,
        );

        clearInteractions(mockSecretBox);
      });

      test('calculateKeyCrc hashes key and returns CRC32 of the hash', () {
        const hashBytes = 42;
        final hashData = Uint8List.fromList(List.filled(128, 42));
        // https://crccalc.com/?crc=2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a&method=crc32&datatype=hex&outtype=hex
        const crcResult = 0xD35231F6;

        when(() => mockGenericHash.bytesMax).thenReturn(hashBytes);
        when(
          () => mockGenericHash.call(
            message: any(named: 'message'),
            outLen: any(named: 'outLen'),
          ),
        ).thenReturn(hashData);

        final result = sut.calculateKeyCrc();

        expect(result, crcResult);

        verifyInOrder([
          () => mockGenericHash.bytesMax,
          () => mockGenericHash.call(
                message: fakeEncryptionKey.data,
                outLen: hashBytes,
              ),
        ]);
      });

      test('maxEncryptedSize returns plain lengh + nonce + mac', () {
        const nonceBytes = 9;
        const macBytes = 13;
        const inpBytes = 20;

        when(() => mockSecretBox.nonceBytes).thenReturn(nonceBytes);
        when(() => mockSecretBox.macBytes).thenReturn(macBytes);

        final result = sut.maxEncryptedSize(Uint8List(inpBytes));

        expect(result, 42);

        verifyInOrder([
          () => mockSecretBox.nonceBytes,
          () => mockSecretBox.macBytes,
        ]);
      });

      group('encrypt', () {
        test('encrypts data using secretBox.easy with a random nonce', () {
          const nonceBytes = 15;
          final nonce = Uint8List.fromList(List.filled(nonceBytes, 64));
          final cipher = Uint8List.fromList(List.filled(20, 77));

          when(() => mockSecretBox.nonceBytes).thenReturn(nonceBytes);
          when(() => mockSecretBox.macBytes).thenReturn(0);
          when(() => mockRandombytes.buf(any())).thenReturn(nonce);
          when(
            () => mockSecretBox.easy(
              message: any(named: 'message'),
              nonce: any(named: 'nonce'),
              key: any(named: 'key'),
            ),
          ).thenReturn(cipher);

          final input = Uint8List.fromList(List.generate(30, (index) => index));
          const inputOffset = 10;
          const inputLength = 15;
          final output = Uint8List.fromList(List.filled(50, 10));
          const outputOffset = 5;

          final result = sut.encrypt(
            input,
            inputOffset,
            inputLength,
            output,
            outputOffset,
          );

          expect(result, nonce.length + cipher.length);
          expect(output, hasLength(50));
          expect(
            output,
            List.filled(5, 10) + nonce + cipher + List.filled(10, 10),
          );

          verifyInOrder([
            () => mockSecretBox.nonceBytes,
            () => mockSecretBox.macBytes,
            () => mockSecretBox.nonceBytes,
            () => mockRandombytes.buf(nonceBytes),
            () => mockSecretBox.easy(
                  message: Uint8List.fromList(
                    List.generate(inputLength, (index) => index + inputOffset),
                  ),
                  nonce: nonce,
                  key: fakeEncryptionKey,
                ),
          ]);
        });

        test('asserts if inp is to short', () {
          expect(
            () => sut.encrypt(Uint8List(10), 5, 10, Uint8List(50), 0),
            throwsA(isA<ArgumentError>()),
          );
        });

        test('asserts if out is to short', () {
          when(() => mockSecretBox.nonceBytes).thenReturn(10);
          when(() => mockSecretBox.macBytes).thenReturn(20);

          expect(
            () => sut.encrypt(Uint8List(50), 5, 10, Uint8List(30), 5),
            throwsA(isA<ArgumentError>()),
          );

          verify(() => mockSecretBox.nonceBytes).called(1);
          verify(() => mockSecretBox.macBytes).called(1);
        });
      });

      group('decrypt', () {
        test('decrypt data using secretBox.openEasy with a random nonce', () {
          const nonceBytes = 15;
          final plain = Uint8List.fromList(List.filled(15, 55));

          when(() => mockSecretBox.nonceBytes).thenReturn(nonceBytes);
          when(() => mockSecretBox.macBytes).thenReturn(0);
          when(
            () => mockSecretBox.openEasy(
              cipherText: any(named: 'cipherText'),
              nonce: any(named: 'nonce'),
              key: any(named: 'key'),
            ),
          ).thenReturn(plain);

          final input = Uint8List.fromList(List.generate(40, (index) => index));
          const inputOffset = 5;
          const inputLength = 25;
          final output = Uint8List.fromList(List.filled(50, 40));
          const outputOffset = 15;

          final result = sut.decrypt(
            input,
            inputOffset,
            inputLength,
            output,
            outputOffset,
          );

          expect(result, plain.length);
          expect(output, hasLength(50));
          expect(output, List.filled(15, 40) + plain + List.filled(20, 40));

          verifyInOrder([
            () => mockSecretBox.nonceBytes,
            () => mockSecretBox.macBytes,
            () => mockSecretBox.nonceBytes,
            () => mockSecretBox.macBytes,
            () => mockSecretBox.nonceBytes,
            () => mockSecretBox.openEasy(
                  cipherText: Uint8List.fromList(
                    List.generate(
                      inputLength - nonceBytes,
                      (index) => index + inputOffset + nonceBytes,
                    ),
                  ),
                  nonce: Uint8List.fromList(
                    List.generate(
                      nonceBytes,
                      (index) => index + inputOffset,
                    ),
                  ),
                  key: fakeEncryptionKey,
                ),
          ]);
        });

        test('asserts if inp is to short for offset/length', () {
          expect(
            () => sut.decrypt(Uint8List(10), 5, 10, Uint8List(50), 0),
            throwsA(isA<ArgumentError>()),
          );
        });

        test('asserts if inp is to short for nonce/cipher', () {
          when(() => mockSecretBox.nonceBytes).thenReturn(15);
          when(() => mockSecretBox.macBytes).thenReturn(15);

          expect(
            () => sut.decrypt(Uint8List(30), 0, 20, Uint8List(50), 0),
            throwsA(isA<ArgumentError>()),
          );
        });

        test('asserts if out is to short', () {
          when(() => mockSecretBox.nonceBytes).thenReturn(10);
          when(() => mockSecretBox.macBytes).thenReturn(20);

          expect(
            () => sut.decrypt(Uint8List(50), 0, 50, Uint8List(15), 5),
            throwsA(isA<ArgumentError>()),
          );

          verify(() => mockSecretBox.nonceBytes).called(2);
          verify(() => mockSecretBox.macBytes).called(2);
        });
      });
    });
  });
}
