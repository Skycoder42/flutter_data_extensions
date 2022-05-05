import 'package:flutter/material.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_demo/src/auth/firebase_auth.dart';
import 'package:flutter_data_demo/src/auth/google_auth.dart';
import 'package:flutter_data_demo/src/setup/providers.dart';
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:flutter_data_sodium/flutter_data_sodium.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../password/application_key_manager.dart';

mixin ApplicationAdapter<T extends DataModel<T>>
    on RemoteAdapter<T>, FirebaseDatabaseAdapter<T>, SodiumRemoteAdapter<T> {
  @override
  String get baseUrl =>
      'https://flutter-data-extensions-default-rtdb.europe-west1.firebasedatabase.app/${read(localIdProvider)}/demo';

  @override
  late final String idToken;

  @override
  Sodium get sodium => read(sodiumProvider);

  @override
  KeyManager get keyManager => read(applicationKeyManagerProvider);

  @override
  @mustCallSuper
  Future<void> onInitialized() async {
    await super.onInitialized();
    await _authenticate();
    await keyManager.initialize();
  }

  Future<void> _authenticate() async {
    final googleCredentials = await read(googleAuthProvider).authorize();
    final firebaseAccount =
        await read(firebaseAuthProvider).loginWithGoogle(googleCredentials);

    read(localIdProvider.notifier).state = firebaseAccount.localId;
    idToken = firebaseAccount.idToken;
  }
}
