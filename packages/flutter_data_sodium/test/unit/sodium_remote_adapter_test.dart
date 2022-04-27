import 'dart:typed_data';

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_sodium/src/encryption/data_cipher.dart';
import 'package:flutter_data_sodium/src/encryption/encrypted_data.dart';
import 'package:flutter_data_sodium/src/key_management/key_manager.dart';
import 'package:flutter_data_sodium/src/sodium_remote_adapter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class TestDataModel extends DataModel<TestDataModel> {
  @override
  final Object? id;

  TestDataModel(this.id);
}

class MockSodium extends Mock implements Sodium {}

class MockKeyManager extends Mock implements KeyManager {}

class MockDataCipher extends Mock implements DataCipher {}

class MockRemoteAdapter<T extends DataModel<T>> extends Mock
    implements RemoteAdapter<T> {
  Map<String, dynamic> mockSerialize(T model) => noSuchMethod(
        Invocation.method(
          const Symbol('serialize'),
          [model],
        ),
      ) as Map<String, dynamic>;

  DeserializedData<T> mockDeserialize(Object? data, {String? key}) =>
      noSuchMethod(
        Invocation.method(
          const Symbol('deserialize'),
          [data],
          {const Symbol('key'): key},
        ),
      ) as DeserializedData<T>;
}

class SutRemoteAdapter extends MockRemoteAdapter<TestDataModel>
    with SodiumRemoteAdapter<TestDataModel> {
  final DataCipher? cipherOverride;

  SutRemoteAdapter([this.cipherOverride]);

  @override
  DataCipher get cipher => cipherOverride ?? super.cipher;
}

class FakeEncryptedData extends Fake implements EncryptedData {
  final Map<String, dynamic> json;

  FakeEncryptedData(this.json);

  @override
  Map<String, dynamic> toJson() => json;
}

void main() {
  setUpAll(() {
    registerFallbackValue(TestDataModel(0));
    registerFallbackValue(FakeEncryptedData(const <String, dynamic>{}));
  });

  group('SodiumRemoteAdapter', () {
    final mockSodium = MockSodium();
    final mockKeyManager = MockKeyManager();

    late SutRemoteAdapter sut;

    setUp(() {
      reset(mockSodium);
      reset(mockKeyManager);

      sut = SutRemoteAdapter();

      when(() => sut.sodium).thenReturn(mockSodium);
      when(() => sut.keyManager).thenReturn(mockKeyManager);
    });

    test('creates DataCipher from sodium and keyManager', () {
      expect(sut.cipher.keyManager, mockKeyManager);
      expect(sut.cipher.sodium, mockSodium);
    });

    group('with cipher', () {
      final mockDataCipher = MockDataCipher();

      setUp(() {
        reset(mockDataCipher);

        sut = SutRemoteAdapter(mockDataCipher);
        assert(sut.cipher == mockDataCipher);
      });

      test('serialize uses super.serialize and the encrypt data', () {
        const testType = 'test-type';
        const testSerializedData = {
          'a': 1,
          'b': true,
          'c': 'yay',
        };
        final testEncryptedData = FakeEncryptedData(const <String, dynamic>{
          'encrypted': true,
        });

        when(() => mockDataCipher.encrypt(any(), any()))
            .thenReturn(testEncryptedData);
        when(() => sut.type).thenReturn(testType);
        when(() => sut.mockSerialize(any())).thenReturn(testSerializedData);

        final testData = TestDataModel(42);
        final result = sut.serialize(testData);

        expect(result, testEncryptedData.json);
        verifyInOrder([
          () => sut.mockSerialize(testData),
          () => mockDataCipher.encrypt(testType, testSerializedData),
        ]);
      });

      group('deserialize', () {
        test('decrypts json object and then forwards data to super.deserialize',
            () {
          const testType = 'test-type';
          const testJson = {
            'id': 42,
            'cipherText': '',
            'mac': '',
            'nonce': '',
            'hasAd': false,
            'keyId': 111,
          };
          const testDecrypted = 42.42;
          final testData = DeserializedData([TestDataModel(42)]);

          when(() => sut.type).thenReturn(testType);
          when(() => sut.mockDeserialize(any(), key: any(named: 'key')))
              .thenReturn(testData);
          when<dynamic>(() => mockDataCipher.decrypt(any(), any()))
              .thenReturn(testDecrypted);

          final result = sut.deserialize(testJson);

          expect(result, testData);

          verifyInOrder<dynamic>([
            () => mockDataCipher.decrypt(
                  testType,
                  EncryptedData(
                    id: 42,
                    cipherText: Uint8List(0),
                    mac: Uint8List(0),
                    nonce: Uint8List(0),
                    hasAd: false,
                    keyId: 111,
                  ),
                ),
            () => sut.mockDeserialize(
                  testDecrypted,
                  key: any(named: 'key', that: isNull),
                ),
          ]);
        });

        test('decrypts json array and then forwards data to super.deserialize',
            () {
          const testType = 'test-type';
          const testJson = [
            {
              'id': 42,
              'cipherText': '',
              'mac': '',
              'nonce': '',
              'hasAd': false,
              'keyId': 111,
            },
            {
              'id': 43,
              'cipherText': '',
              'mac': '',
              'nonce': '',
              'hasAd': false,
              'keyId': 111,
            }
          ];
          const testDecrypted = 42.42;
          final testData = DeserializedData([
            TestDataModel(42),
            TestDataModel(43),
          ]);

          when(() => sut.type).thenReturn(testType);
          when(() => sut.mockDeserialize(any(), key: any(named: 'key')))
              .thenReturn(testData);
          when<dynamic>(() => mockDataCipher.decrypt(any(), any()))
              .thenReturn(testDecrypted);

          final result = sut.deserialize(testJson);

          expect(result, testData);

          final captured = verify(
            () => sut.mockDeserialize(
              captureAny(),
              key: any(named: 'key', that: isNull),
            ),
          ).captured.single as Iterable;
          expect(captured, [testDecrypted, testDecrypted]);

          verifyInOrder<dynamic>([
            () => mockDataCipher.decrypt(
                  testType,
                  EncryptedData(
                    id: 42,
                    cipherText: Uint8List(0),
                    mac: Uint8List(0),
                    nonce: Uint8List(0),
                    hasAd: false,
                    keyId: 111,
                  ),
                ),
            () => mockDataCipher.decrypt(
                  testType,
                  EncryptedData(
                    id: 43,
                    cipherText: Uint8List(0),
                    mac: Uint8List(0),
                    nonce: Uint8List(0),
                    hasAd: false,
                    keyId: 111,
                  ),
                ),
          ]);
        });

        test('forwards null data to super.deserialize', () {
          const testType = 'test-type';
          const testKey = 'test-key';
          const testData = DeserializedData<TestDataModel>([]);

          when(() => sut.type).thenReturn(testType);
          when(() => sut.mockDeserialize(any(), key: any(named: 'key')))
              .thenReturn(testData);

          final result = sut.deserialize(null, key: testKey);

          expect(result, testData);

          verify(() => sut.mockDeserialize(null, key: testKey));
          verifyNever<dynamic>(() => mockDataCipher.decrypt(any(), any()));
        });

        test('calls super.deserialize with null for empty strings', () {
          const testType = 'test-type';
          const testKey = 'test-key';
          const testData = DeserializedData<TestDataModel>([]);

          when(() => sut.type).thenReturn(testType);
          when(() => sut.mockDeserialize(any(), key: any(named: 'key')))
              .thenReturn(testData);

          final result = sut.deserialize('', key: testKey);

          expect(result, testData);

          verify(() => sut.mockDeserialize(null, key: testKey));
          verifyNever<dynamic>(() => mockDataCipher.decrypt(any(), any()));
        });

        test('throws for other data values', () {
          const testType = 'test-type';
          when(() => sut.type).thenReturn(testType);

          expect(
            () => sut.deserialize(42),
            throwsFormatException,
          );

          verifyNever(() => sut.mockDeserialize(any(), key: any(named: 'key')));
          verifyNever<dynamic>(() => mockDataCipher.decrypt(any(), any()));
        });
      });
    });
  });
}
