@TestOn('dart-vm')

// ignore_for_file: invalid_use_of_protected_member

import 'dart:isolate';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_data_sodium/src/key_management/isolate/parallel_computation_failure.dart';
import 'package:flutter_data_sodium/src/key_management/isolate/parallel_master_key_computation.dart';
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
}

class SutKeyManager extends PassphraseBasedKeyManager
    with ParallelMasterKeyComputation {
  static const keyLength = 33;
  static const password = 'hello test';
  static final salt = Uint8List.fromList(List.filled(10, 10));
  static const memLimit = 111;
  static const opsLimit = 222;

  bool simulateError = false;

  SutKeyManager({
    required Sodium sodium,
    Clock? clock,
  }) : super(
          sodium: sodium,
          clock: clock,
        );

  @override
  CreateSodiumFn get sodiumFactory => () {
        if (Isolate.current.debugName !=
            ParallelMasterKeyComputation.isolateDebugName) {
          throw TestFailure(
            'Expected to be in isolate with name '
            '${ParallelMasterKeyComputation.isolateDebugName}, '
            'but was in isolate ${Isolate.current.debugName}!',
          );
        }

        final mockSodium = MockSodium();
        final mockCrypto = MockCrypto();
        final mockPwhash = MockPwhash();

        when(() => mockSodium.crypto).thenReturn(mockCrypto);
        when(() => mockCrypto.pwhash).thenReturn(mockPwhash);
        final whenPwhash = when(
          () => mockPwhash.call(
            outLen: keyLength,
            password: password.toCharArray(),
            salt: salt,
            opsLimit: opsLimit,
            memLimit: memLimit,
          ),
        );
        if (simulateError) {
          whenPwhash.thenThrow(Exception('simulated error'));
        } else {
          whenPwhash.thenReturn(FakeSecureKey(keyLength));
        }

        return mockSodium;
      };

  @override
  Future<SecureKey> loadLocalKey(int keyLength) => throw UnimplementedError();

  @override
  Future<MasterKeyComponents> loadMasterKeyComponents() =>
      throw UnimplementedError();
}

void main() {
  group('ParallelMasterKeyComputation', () {
    late SutKeyManager sut;

    setUp(() {
      sut = SutKeyManager(sodium: MockSodium());
    });

    group('deriveKey', () {
      test('invokes computeMasterKey on isolate threat', () {
        expect(
          sut.deriveKey(
            MasterKeyComponents(
              password: SutKeyManager.password,
              salt: SutKeyManager.salt,
              memLimit: SutKeyManager.memLimit,
              opsLimit: SutKeyManager.opsLimit,
            ),
            SutKeyManager.keyLength,
          ),
          completion(
            isA<FakeSecureKey>().having(
              (key) => key.length,
              'length',
              SutKeyManager.keyLength,
            ),
          ),
        );
      });

      test('forwards exceptions from isolate to caller', () {
        sut.simulateError = true;

        expect(
          sut.deriveKey(
            MasterKeyComponents(
              password: SutKeyManager.password,
              salt: SutKeyManager.salt,
              memLimit: SutKeyManager.memLimit,
              opsLimit: SutKeyManager.opsLimit,
            ),
            SutKeyManager.keyLength,
          ),
          throwsA(isA<ParallelComputationFailure>()),
        );
      });
    });
  });
}
