@TestOn('dart-vm')

// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_data_sodium/src/key_management/parallel_master_key_computation.dart';
import 'package:flutter_data_sodium/src/key_management/passphrase_based_key_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockSodium extends Mock implements Sodium {}

class MockCrypto extends Mock implements Crypto {}

class MockPwhash extends Mock implements Pwhash {}

class FakeSecureKey extends Fake implements SecureKey {
  @override
  final int length;

  FakeSecureKey(this.length);

  @override
  dynamic get nativeHandle => this;
}

class MockParallelMasterKeyComputation extends Mock
    implements ParallelMasterKeyComputation {}

class SutKeyManager extends PassphraseBasedKeyManager
    with ParallelMasterKeyComputation {
  final MockParallelMasterKeyComputation mock;

  SutKeyManager({
    required this.mock,
    required Sodium sodium,
    Clock? clock,
  }) : super(
          sodium: sodium,
          clock: clock,
        );

  @override
  CreateSodiumFn get sodiumFactory => mock.sodiumFactory;

  @override
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) =>
      mock.compute<dynamic, dynamic>(
        (dynamic m) async => callback(m as Q),
        message,
      ) as Future<R>;

  @override
  Future<MasterKeyComponents> loadMasterKeyComponents() =>
      mock.loadMasterKeyComponents();
}

void main() {
  group('ParallelMasterKeyComputation', () {
    const keyLength = 33;
    const password = 'hello test';
    final salt = Uint8List.fromList(List.filled(10, 10));
    const memLimit = 111;
    const opsLimit = 222;

    final mockSodium = MockSodium();
    final mockCrypto = MockCrypto();
    final mockPwhash = MockPwhash();
    final sutMock = MockParallelMasterKeyComputation();

    late SutKeyManager sut;

    setUp(() {
      resetMocktailState();

      when(() => mockSodium.crypto).thenReturn(mockCrypto);
      when(() => mockCrypto.pwhash).thenReturn(mockPwhash);

      when(
        () => mockPwhash.call(
          outLen: keyLength,
          password: password.toCharArray(),
          salt: salt,
          opsLimit: opsLimit,
          memLimit: memLimit,
        ),
      ).thenReturn(FakeSecureKey(keyLength));

      sut = SutKeyManager(mock: sutMock, sodium: mockSodium);
    });

    group('deriveKey', () {
      test('invokes computeMasterKey via compute callback', () {
        when(() => sutMock.sodiumFactory).thenReturn(() => mockSodium);
        when(() => sutMock.compute<dynamic, dynamic>(any(), any<dynamic>()))
            .thenAnswer(
          (invocation) async {
            final callback = invocation.positionalArguments[0]
                as ComputeCallback<dynamic, dynamic>;
            final dynamic message = invocation.positionalArguments[1];
            final dynamic result = await callback(message);
            return result;
          },
        );
        when(() => mockSodium.secureHandle(any<dynamic>())).thenAnswer(
          (invocation) => invocation.positionalArguments.first as FakeSecureKey,
        );

        expect(
          sut.deriveKey(
            MasterKeyComponents(
              password: password,
              salt: salt,
              memLimit: memLimit,
              opsLimit: opsLimit,
            ),
            keyLength,
          ),
          completion(
            isA<FakeSecureKey>().having(
              (key) => key.length,
              'length',
              keyLength,
            ),
          ),
        );

        verifyInOrder([
          () => sutMock.sodiumFactory,
          () => sutMock.compute<dynamic, dynamic>(any(), any<dynamic>()),
        ]);
      });
    });
  });
}
