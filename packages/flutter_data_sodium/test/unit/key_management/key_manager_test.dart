// ignore_for_file: invalid_use_of_protected_member

import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:dart_test_tools/test.dart';
import 'package:flutter_data_sodium/src/key_management/key_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

class MockSodium extends Mock implements Sodium {}

class MockCrypto extends Mock implements Crypto {}

class MockKdf extends Mock implements Kdf {}

class MockShortHash extends Mock implements ShortHash {}

class MockKeyManager extends Mock implements KeyManager {}

class MockSecureKey extends Mock implements SecureKey {}

class SutKeyManager extends KeyManager {
  final MockKeyManager mock;

  SutKeyManager({
    required this.mock,
    required Sodium sodium,
    required Clock clock,
  }) : super(
          sodium: sodium,
          clock: clock,
        );

  @override
  Future<SecureKey> loadLocalKey(int keyLength) => mock.loadLocalKey(keyLength);

  @override
  Future<SecureKey> loadRemoteMasterKey(int keyLength) =>
      mock.loadRemoteMasterKey(keyLength);
}

void main() {
  setUpAll(() {
    registerFallbackValue(MockSecureKey());
    registerFallbackValue(Uint8List(0));
  });

  group('KeyManager', () {
    const kdfKeyBytes = 42;

    final mockSodium = MockSodium();
    final mockCrypto = MockCrypto();
    final mockKdf = MockKdf();
    final mockShortHash = MockShortHash();
    final mockKeyManager = MockKeyManager();

    late SutKeyManager sut;

    setUp(() {
      reset(mockSodium);
      reset(mockCrypto);
      reset(mockKdf);
      reset(mockShortHash);
      reset(mockKeyManager);

      when(() => mockSodium.crypto).thenReturn(mockCrypto);
      when(() => mockCrypto.kdf).thenReturn(mockKdf);
      when(() => mockCrypto.shortHash).thenReturn(mockShortHash);

      when(() => mockKdf.keyBytes).thenReturn(kdfKeyBytes);

      sut = SutKeyManager(
        mock: mockKeyManager,
        sodium: mockSodium,
        clock: clock,
      );
    });

    test('initialize loads the master key', () async {
      when(() => mockKeyManager.loadRemoteMasterKey(any()))
          .thenReturnAsync(MockSecureKey());

      await sut.initialize();

      verifyInOrder([
        () => mockKdf.keyBytes,
        () => mockKeyManager.loadRemoteMasterKey(kdfKeyBytes),
      ]);
    });

    group('initialized', () {
      final masterKey = MockSecureKey();
      const testType = 'test-types';
      const hashKeyBytes = 24;

      When<SecureKey> _whenKdf(String context, [int? subkeyId]) => when(
            () => mockKdf.deriveFromKey(
              masterKey: any(named: 'masterKey'),
              context: context,
              subkeyId: subkeyId ?? any(named: 'subkeyId'),
              subkeyLen: any(named: 'subkeyLen'),
            ),
          );

      When<Uint8List> _whenHash() => when(
            () => mockShortHash.call(
              message: any(named: 'message'),
              key: any(named: 'key'),
            ),
          );

      void _whenHashThenReturn(int keyId) => _whenHash().thenReturn(
            (ByteData(8)..setUint64(0, keyId)).buffer.asUint8List(),
          );

      setUp(() {
        when(() => mockKeyManager.loadRemoteMasterKey(any()))
            .thenReturnAsync(masterKey);
        sut.initialize();

        when(() => mockShortHash.keyBytes).thenReturn(hashKeyBytes);

        clearInteractions(mockKdf);
        clearInteractions(mockKeyManager);
      });

      group('remoteKeyForTypeAndId', () {
        test('recursively derives all keys from the master key once', () {
          const keyId = 111;
          const keyLength = 50;

          final typeHashingKey = MockSecureKey();
          final repositoryKey = MockSecureKey();
          final repositoryRotKey = MockSecureKey();
          const typeKeyId = 42;

          _whenKdf('fds_type').thenReturn(typeHashingKey);
          _whenKdf('fds_repo').thenReturn(repositoryKey);
          _whenKdf('fds_rota').thenReturn(repositoryRotKey);
          _whenHashThenReturn(typeKeyId);

          // get key once
          final key = sut.remoteKeyForTypeAndId(testType, keyId, keyLength);

          expect(key, repositoryRotKey);
          verifyInOrder([
            () => mockShortHash.keyBytes,
            () => mockKdf.deriveFromKey(
                  masterKey: masterKey,
                  context: 'fds_type',
                  subkeyId: 0,
                  subkeyLen: hashKeyBytes,
                ),
            () => mockShortHash.call(
                  message: testType.toCharArray().unsignedView(),
                  key: typeHashingKey,
                ),
            () => typeHashingKey.dispose(),
            () => mockKdf.keyBytes,
            () => mockKdf.deriveFromKey(
                  masterKey: masterKey,
                  context: 'fds_repo',
                  subkeyId: typeKeyId,
                  subkeyLen: kdfKeyBytes,
                ),
            () => mockKdf.deriveFromKey(
                  masterKey: repositoryKey,
                  context: 'fds_rota',
                  subkeyId: keyId,
                  subkeyLen: keyLength,
                ),
            () => repositoryKey.dispose(),
          ]);
          verifyNever(() => repositoryRotKey.dispose());
          verifyNoMoreInteractions(mockKdf);
          verifyNoMoreInteractions(mockShortHash);

          // get key again
          final key2 = sut.remoteKeyForTypeAndId(testType, keyId, keyLength);

          expect(key2, repositoryRotKey);
          verifyNoMoreInteractions(mockKdf);
          verifyNoMoreInteractions(mockShortHash);
        });

        test('disposes typeHashingKey if shortHash fails', () {
          const keyId = 111;
          const keyLength = 50;

          final typeHashingKey = MockSecureKey();

          _whenKdf('fds_type').thenReturn(typeHashingKey);
          _whenHash().thenThrow(Exception('hash error'));

          expect(
            () => sut.remoteKeyForTypeAndId(testType, keyId, keyLength),
            throwsException,
          );

          verifyInOrder([
            () => mockShortHash.keyBytes,
            () => mockKdf.deriveFromKey(
                  masterKey: masterKey,
                  context: 'fds_type',
                  subkeyId: 0,
                  subkeyLen: hashKeyBytes,
                ),
            () => mockShortHash.call(
                  message: testType.toCharArray().unsignedView(),
                  key: typeHashingKey,
                ),
            () => typeHashingKey.dispose(),
          ]);
          verifyNoMoreInteractions(mockKdf);
          verifyNoMoreInteractions(mockShortHash);
        });

        test('disposes repository key if rotation key derivation fails', () {
          const keyId = 111;
          const keyLength = 50;

          final typeHashingKey = MockSecureKey();
          final repositoryKey = MockSecureKey();
          const typeKeyId = 42;

          _whenKdf('fds_type').thenReturn(typeHashingKey);
          _whenKdf('fds_repo').thenReturn(repositoryKey);
          _whenKdf('fds_rota').thenThrow(Exception('fds_rota error'));
          _whenHashThenReturn(typeKeyId);

          expect(
            () => sut.remoteKeyForTypeAndId(testType, keyId, keyLength),
            throwsException,
          );

          verifyInOrder([
            () => mockShortHash.keyBytes,
            () => mockKdf.deriveFromKey(
                  masterKey: masterKey,
                  context: 'fds_type',
                  subkeyId: 0,
                  subkeyLen: hashKeyBytes,
                ),
            () => mockShortHash.call(
                  message: testType.toCharArray().unsignedView(),
                  key: typeHashingKey,
                ),
            () => typeHashingKey.dispose(),
            () => mockKdf.keyBytes,
            () => mockKdf.deriveFromKey(
                  masterKey: masterKey,
                  context: 'fds_repo',
                  subkeyId: typeKeyId,
                  subkeyLen: kdfKeyBytes,
                ),
            () => mockKdf.deriveFromKey(
                  masterKey: repositoryKey,
                  context: 'fds_rota',
                  subkeyId: keyId,
                  subkeyLen: keyLength,
                ),
            () => repositoryKey.dispose(),
          ]);
          verifyNoMoreInteractions(mockKdf);
          verifyNoMoreInteractions(mockShortHash);
        });
      });

      testData<Tuple2<DateTime, int>>(
          'remoteKeyForType calculates key id from timestamp', [
        Tuple2(DateTime.utc(2021, 9, 29), 629),
        Tuple2(DateTime.utc(2021, 9, 30), 630),
        Tuple2(DateTime.utc(2021, 10, 29), 630),
        Tuple2(DateTime.utc(2021, 10, 30), 631),
      ], (fixture) async {
        sut = SutKeyManager(
          mock: mockKeyManager,
          sodium: mockSodium,
          clock: Clock.fixed(fixture.item1),
        );
        await sut.initialize();
        clearInteractions(mockKdf);
        clearInteractions(mockKeyManager);

        const keyLength = 34;

        final typeHashingKey = MockSecureKey();
        final repositoryKey = MockSecureKey();
        final repositoryRotKey = MockSecureKey();
        const typeKeyId = 24;

        _whenKdf('fds_type').thenReturn(typeHashingKey);
        _whenKdf('fds_repo').thenReturn(repositoryKey);
        _whenKdf('fds_rota').thenReturn(repositoryRotKey);
        _whenHashThenReturn(typeKeyId);

        final keyInfo = sut.remoteKeyForType(testType, keyLength);

        expect(keyInfo.keyId, fixture.item2);
        expect(keyInfo.secureKey, repositoryRotKey);
        verifyInOrder([
          () => mockShortHash.keyBytes,
          () => mockKdf.deriveFromKey(
                masterKey: masterKey,
                context: 'fds_type',
                subkeyId: 0,
                subkeyLen: hashKeyBytes,
              ),
          () => mockShortHash.call(
                message: testType.toCharArray().unsignedView(),
                key: typeHashingKey,
              ),
          () => typeHashingKey.dispose(),
          () => mockKdf.keyBytes,
          () => mockKdf.deriveFromKey(
                masterKey: masterKey,
                context: 'fds_repo',
                subkeyId: typeKeyId,
                subkeyLen: kdfKeyBytes,
              ),
          () => mockKdf.deriveFromKey(
                masterKey: repositoryKey,
                context: 'fds_rota',
                subkeyId: fixture.item2,
                subkeyLen: keyLength,
              ),
          () => repositoryKey.dispose(),
        ]);
        verifyNever(() => repositoryRotKey.dispose());
        verifyNoMoreInteractions(mockKdf);
        verifyNoMoreInteractions(mockShortHash);
      });

      group('dispose', () {
        test('disposes master key', () {
          sut.dispose();

          verify(() => masterKey.dispose());
        });

        test('disposes cached keys', () {
          const keyId = 111;
          const keyLength = 50;

          final typeHashingKey = MockSecureKey();
          final repositoryKey = MockSecureKey();
          final repositoryRotKey = MockSecureKey();
          const typeKeyId = 42;

          _whenKdf('fds_type').thenReturn(typeHashingKey);
          _whenKdf('fds_repo').thenReturn(repositoryKey);
          _whenKdf('fds_rota').thenReturn(repositoryRotKey);
          _whenHashThenReturn(typeKeyId);

          // get key once
          final key = sut.remoteKeyForTypeAndId(testType, keyId, keyLength);

          expect(key, repositoryRotKey);
          verify(
            () => mockKdf.deriveFromKey(
              masterKey: any(named: 'masterKey'),
              context: any(named: 'context'),
              subkeyId: any(named: 'subkeyId'),
              subkeyLen: any(named: 'subkeyLen'),
            ),
          ).called(3);

          sut.dispose();

          // get key again
          final key2 = sut.remoteKeyForTypeAndId(testType, keyId, keyLength);

          expect(key2, repositoryRotKey);
          verify(
            () => mockKdf.deriveFromKey(
              masterKey: any(named: 'masterKey'),
              context: any(named: 'context'),
              subkeyId: any(named: 'subkeyId'),
              subkeyLen: any(named: 'subkeyLen'),
            ),
          ).called(3);
        });
      });
    });
  });
}
