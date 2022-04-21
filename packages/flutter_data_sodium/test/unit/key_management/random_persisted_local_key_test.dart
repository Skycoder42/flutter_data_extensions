// ignore_for_file: invalid_use_of_protected_member

import 'package:dart_test_tools/test.dart';
import 'package:flutter_data_sodium/src/key_management/key_manager.dart';
import 'package:flutter_data_sodium/src/key_management/random_persisted_local_key.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockSodium extends Mock implements Sodium {}

class MockKeyManager extends Mock implements KeyManager {}

class SutKeyManager extends MockKeyManager with RandomPersistedLocalKey {}

class MockSecureKey extends Mock implements SecureKey {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockSecureKey());
  });

  group('RandomPersistedLocalKey', () {
    final mockSodium = MockSodium();

    late SutKeyManager sut;

    setUp(() {
      reset(mockSodium);

      sut = SutKeyManager();

      when(() => sut.sodium).thenReturn(mockSodium);
    });

    group('loadLocalKey', () {
      const keyLength = 11;
      final testKey = MockSecureKey();

      setUp(() {
        reset(testKey);

        when(() => testKey.length).thenReturn(keyLength);
      });

      test('returns stored key if it exists', () async {
        when(() => sut.loadKeyFromStorage()).thenReturnAsync(testKey);

        final key = await sut.loadLocalKey(keyLength);

        expect(key, testKey);

        verifyInOrder([
          () => sut.loadKeyFromStorage(),
          () => testKey.length,
        ]);
        verifyNoMoreInteractions(sut);
        verifyNoMoreInteractions(testKey);
      });

      test('throws if stored key is not valid', () async {
        when(() => sut.loadKeyFromStorage()).thenReturnAsync(testKey);

        await expectLater(
          () => sut.loadLocalKey(keyLength + 10),
          throwsStateError,
        );

        verifyInOrder([
          () => sut.loadKeyFromStorage(),
          () => testKey.length,
          () => testKey.dispose(),
        ]);
        verifyNoMoreInteractions(sut);
      });

      test('generates and stores new random key if none was stored yet',
          () async {
        when(() => sut.loadKeyFromStorage()).thenReturnAsync(null);
        when(() => sut.persisKeyInStorage(any())).thenReturnAsync(null);
        when(() => mockSodium.secureRandom(any())).thenReturn(testKey);

        final key = await sut.loadLocalKey(keyLength);

        expect(key, testKey);

        verifyInOrder([
          () => sut.loadKeyFromStorage(),
          () => sut.sodium,
          () => mockSodium.secureRandom(keyLength),
          () => sut.persisKeyInStorage(testKey),
        ]);
        verifyNoMoreInteractions(sut);
        verifyNoMoreInteractions(testKey);
      });

      test('disposes generated key if persisting fails', () async {
        when(() => sut.loadKeyFromStorage()).thenReturnAsync(null);
        when(() => sut.persisKeyInStorage(any())).thenThrow(Exception('error'));
        when(() => mockSodium.secureRandom(any())).thenReturn(testKey);

        await expectLater(
          () => sut.loadLocalKey(keyLength),
          throwsException,
        );

        verifyInOrder([
          () => sut.loadKeyFromStorage(),
          () => sut.sodium,
          () => mockSodium.secureRandom(keyLength),
          () => sut.persisKeyInStorage(testKey),
          () => testKey.dispose(),
        ]);
        verifyNoMoreInteractions(sut);
        verifyNoMoreInteractions(testKey);
      });
    });
  });
}
