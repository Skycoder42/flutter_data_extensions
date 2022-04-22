import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_sodium/src/hive/configure_repository_local_storage.dart';
import 'package:flutter_data_sodium/src/hive/sodium_hive_local_storage.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockHive extends Mock implements HiveInterface {}

class MockSodium extends Mock implements Sodium {}

class MockCrypto extends Mock implements Crypto {}

class MockSecretBox extends Mock implements SecretBox {}

class FakeSecureKey extends Fake implements SecureKey {
  @override
  final int length;

  FakeSecureKey(this.length);
}

void main() {
  group('configureRepositoryLocalStorageSodium', () {
    const keyLength = 11;
    final fakeEncryptionKey = FakeSecureKey(keyLength);
    // ignore: prefer_function_declarations_over_variables
    final baseDirFn = () => '';
    final mockHive = MockHive();
    final mockSodium = MockSodium();
    final mockCrypto = MockCrypto();
    final mockSecretBox = MockSecretBox();

    setUp(() {
      reset(mockHive);
      reset(mockSodium);
      reset(mockCrypto);
      reset(mockSecretBox);

      when(() => mockSodium.crypto).thenReturn(mockCrypto);
      when(() => mockCrypto.secretBox).thenReturn(mockSecretBox);
      when(() => mockSecretBox.keyBytes).thenReturn(keyLength);
    });

    test('creates override with SodiumHiveLocalStorage provider', () {
      final sutOverride = configureRepositoryLocalStorageSodium(
        sodium: mockSodium,
        encryptionKey: fakeEncryptionKey,
        baseDirFn: baseDirFn,
      );

      final providerContainer = ProviderContainer(
        overrides: [
          hiveProvider.overrideWithValue(mockHive),
          sutOverride,
        ],
      );

      final instance = providerContainer.read(hiveLocalStorageProvider);

      expect(
        instance,
        isA<SodiumHiveLocalStorage>()
            .having((sut) => sut.hive, 'hive', mockHive)
            .having((sut) => sut.baseDirFn, 'baseDirFn', baseDirFn)
            .having(
              (sut) => sut.sodiumHiveCipher.sodium,
              'sodiumHiveCipher.sodium',
              mockSodium,
            )
            .having(
              (sut) => sut.sodiumHiveCipher.encryptionKey,
              'sodiumHiveCipher.encryptionKey',
              fakeEncryptionKey,
            ),
      );
    });
  });
}
