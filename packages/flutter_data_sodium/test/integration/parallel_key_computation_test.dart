@TestOn('dart-vm')

// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:isolate';

// ignore: test_library_import
import 'package:flutter_data_sodium/flutter_data_sodium.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'setup/sodium_setup_vm.dart';

void main() {
  test('Can asynchronously compute master key', () async {
    final sut = _TestKeyManager(
      sodium: await _sodiumFactory(),
      masterKeyComponents: MasterKeyComponents(
        password: 'password',
        salt: 'SaltSaltSaltSalt'.toCharArray().unsignedView(),
      ),
    );

    final masterKey = await sut.loadRemoteMasterKey(42);
    expect(
      masterKey.extractBytes(),
      equals(
        [
          158,
          233,
          13,
          203,
          146,
          92,
          10,
          142,
          27,
          166,
          157,
          107,
          178,
          158,
          141,
          23,
          232,
          207,
          166,
          229,
          41,
          157,
          182,
          244,
          174,
          168,
          231,
          144,
          30,
          69,
          4,
          101,
          165,
          4,
          6,
          74,
          84,
          232,
          235,
          104,
          155,
          72
        ],
      ),
    );
  });
}

class _TestKeyManager extends PassphraseBasedKeyManager
    with ParallelMasterKeyComputation {
  final MasterKeyComponents masterKeyComponents;

  _TestKeyManager({
    required Sodium sodium,
    required this.masterKeyComponents,
  }) : super(sodium: sodium);

  @override
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) async {
    const isolateName = 'TestKeyManager.compute';
    final resultPort = ReceivePort('$isolateName.result');
    final isolate = await Isolate.spawn<_IsolateMessage<Q, R>>(
      _isolateMain,
      _IsolateMessage(callback, message, resultPort.sendPort),
      debugName: isolateName,
    );
    try {
      return await resultPort.cast<R>().first;
    } catch (e) {
      isolate.kill();
      rethrow;
    } finally {
      resultPort.close();
    }
  }

  @override
  MasterKeyComponents loadMasterKeyComponents(int saltLength) {
    assert(saltLength == masterKeyComponents.salt.length);
    return masterKeyComponents;
  }

  @override
  CreateSodiumFn get sodiumFactory => _sodiumFactory;
}

class _SodiumFactory = Object with SodiumSetup;

Future<Sodium> _sodiumFactory() async {
  final messages = <String>[];
  try {
    return await const _SodiumFactory().loadSodium(
      expect: (dynamic actual, expected) {
        final matchState = <dynamic, dynamic>{};
        if (!expected.matches(actual, matchState)) {
          throw TestFailure(
            expected
                .describeMismatch(
                  actual,
                  StringDescription(),
                  matchState,
                  false,
                )
                .toString(),
          );
        }
      },
      printOnFailure: messages.add,
    );
  } catch (e) {
    for (final message in messages) {
      // ignore: avoid_print
      print('ERROR: $message');
    }
    rethrow;
  }
}

class _IsolateMessage<Q, R> {
  final ComputeCallback<Q, R> callback;
  final Q message;
  final SendPort resultPort;

  _IsolateMessage(this.callback, this.message, this.resultPort);

  FutureOr<R> call() => callback(message);
}

Future<void> _isolateMain<Q, R>(_IsolateMessage<Q, R> isolateMessage) async {
  final result = await isolateMessage();
  Isolate.exit(isolateMessage.resultPort, result);
}
