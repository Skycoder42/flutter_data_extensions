import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' as ff;
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_demo/src/password/password_controller.dart';
import 'package:flutter_data_demo/src/setup/providers.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:flutter_data_sodium/flutter_data_sodium.dart';

// ignore: implementation_imports
import 'package:sodium_libs/src/platforms/platforms.ffi.dart';

final applicationKeyManagerProvider = Provider(
  (ref) => ApplicationKeyManager(
    sodium: ref.watch(sodiumProvider),
    passwordController: ref.watch(passwordControllerProvider.notifier),
    getLocalId: () => ref.read(localIdProvider),
  ),
);

class ApplicationKeyManager extends PassphraseBasedKeyManager
    with ParallelMasterKeyComputation {
  final PasswordController passwordController;
  final String Function() getLocalId;

  ApplicationKeyManager({
    required Sodium sodium,
    required this.passwordController,
    required this.getLocalId,
  }) : super(sodium: sodium);

  @override
  FutureOr<MasterKeyComponents> loadMasterKeyComponents(int saltLength) async {
    final password = await _letUserInputPassword();
    final salt = _generateSaltForUser(saltLength);
    return MasterKeyComponents(password: password, salt: salt);
  }

  Future<String> _letUserInputPassword() =>
      passwordController.requestPassword();

  Uint8List _generateSaltForUser(int saltLength) => sodium.crypto.genericHash(
        message: getLocalId().toCharArray().unsignedView(),
        outLen: saltLength,
      );

  @override
  CreateSodiumFn get sodiumFactory => _sodiumFactory;

  @override
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message) =>
      ff.compute(callback, message);

  static Future<Sodium> _sodiumFactory() {
    if (Platform.isAndroid) {
      SodiumAndroid.registerWith();
    } else if (Platform.isIOS) {
      SodiumIos.registerWith();
    } else if (Platform.isLinux) {
      SodiumLinux.registerWith();
    } else if (Platform.isWindows) {
      SodiumWindows.registerWith();
    } else if (Platform.isMacOS) {
      SodiumMacos.registerWith();
    } else {
      throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported by sodium_libs',
      );
    }

    return SodiumPlatform.instance.loadSodium();
  }
}
