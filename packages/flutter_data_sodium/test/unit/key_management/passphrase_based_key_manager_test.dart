// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_data_sodium/src/key_management/passphrase_based_key_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

class MockSodium extends Mock implements Sodium {}

class MockCrypto extends Mock implements Crypto {}

class MockPwhash extends Mock implements Pwhash {}

class FakeSecureKey extends Fake implements SecureKey {}

class MockPassphraseBasedKeyManager extends Mock
    implements PassphraseBasedKeyManager {}

class SutPassphraseBasedKeyManager extends PassphraseBasedKeyManager {
  final MockPassphraseBasedKeyManager mock;

  SutPassphraseBasedKeyManager({
    required this.mock,
    required Sodium sodium,
    Clock? clock,
  }) : super(
          sodium: sodium,
          clock: clock,
        );

  @override
  FutureOr<MasterKeyComponents> loadMasterKeyComponents() =>
      mock.loadMasterKeyComponents();
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(Int8List(0));
  });

  group('PassphraseBasedKeyManager', () {
    final mockSodium = MockSodium();
    final mockCrypto = MockCrypto();
    final mockPwhash = MockPwhash();
    const keyLength = 50;
    final testKey = FakeSecureKey();

    setUp(() {
      reset(mockSodium);
      reset(mockCrypto);
      reset(mockPwhash);

      when(() => mockSodium.crypto).thenReturn(mockCrypto);
      when(() => mockCrypto.pwhash).thenReturn(mockPwhash);

      when(
        () => mockPwhash.call(
          outLen: any(named: 'outLen'),
          password: any(named: 'password'),
          salt: any(named: 'salt'),
          opsLimit: any(named: 'opsLimit'),
          memLimit: any(named: 'memLimit'),
        ),
      ).thenReturn(testKey);
    });

    group('static', () {
      group('computeMasterKey', () {
        test('invokes pwhash with master key components and key length', () {
          final components = MasterKeyComponents(
            password: 'hello test',
            salt: Uint8List.fromList(List.filled(10, 10)),
            memLimit: 111,
            opsLimit: 222,
          );

          final key = PassphraseBasedKeyManager.computeMasterKey(
            sodium: mockSodium,
            masterKeyComponents: components,
            keyLength: keyLength,
          );

          expect(key, testKey);
          verify(
            () => mockPwhash.call(
              outLen: keyLength,
              password: components.password.toCharArray(),
              salt: components.salt,
              opsLimit: components.opsLimit!,
              memLimit: components.memLimit!,
            ),
          );
        });

        test('uses sensitive default values if no ops/mem limit are given', () {
          const opsLimit = 1000;
          const memLimit = 2000;
          final components = MasterKeyComponents(
            password: 'hello test',
            salt: Uint8List.fromList(List.filled(10, 10)),
          );

          when(() => mockPwhash.opsLimitSensitive).thenReturn(opsLimit);
          when(() => mockPwhash.memLimitSensitive).thenReturn(memLimit);

          final key = PassphraseBasedKeyManager.computeMasterKey(
            sodium: mockSodium,
            masterKeyComponents: components,
            keyLength: keyLength,
          );

          expect(key, testKey);
          verifyInOrder([
            () => mockPwhash.opsLimitSensitive,
            () => mockPwhash.memLimitSensitive,
            () => mockPwhash.call(
                  outLen: keyLength,
                  password: components.password.toCharArray(),
                  salt: components.salt,
                  opsLimit: opsLimit,
                  memLimit: memLimit,
                ),
          ]);
        });
      });
    });

    group('instance', () {
      final mockSut = MockPassphraseBasedKeyManager();
      final clock = Clock.fixed(DateTime.now());

      late SutPassphraseBasedKeyManager sut;

      setUp(() {
        reset(mockSut);

        sut = SutPassphraseBasedKeyManager(
          mock: mockSut,
          sodium: mockSodium,
          clock: clock,
        );
      });

      test('loadRemoteMasterKey derives key from loaded components', () async {
        final components = MasterKeyComponents(
          password: 'password test',
          salt: Uint8List.fromList(List.filled(15, 5)),
          memLimit: 333,
          opsLimit: 444,
        );

        when(() => mockSut.loadMasterKeyComponents()).thenReturn(components);

        final key = await sut.loadRemoteMasterKey(keyLength);

        expect(key, testKey);
        verifyInOrder([
          () => mockSut.loadMasterKeyComponents(),
          () => mockPwhash.call(
                outLen: keyLength,
                password: components.password.toCharArray(),
                salt: components.salt,
                opsLimit: components.opsLimit!,
                memLimit: components.memLimit!,
              ),
        ]);
      });
    });
  });
}
