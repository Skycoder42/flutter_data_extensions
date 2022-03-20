import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'config_setup.dart';
import 'di_setup.dart';
import 'models/account.dart';

mixin AccountSetup on DiSetup, ConfigSetup {
  static late final accountProvider = StateProvider(
    (ref) => const Account(idToken: '', localId: ''),
  );

  @override
  @mustCallSuper
  Future<void> setUpAll() async {
    await super.setUpAll();

    final accountResponse = await http.post(_createUri('signUp'));
    printOnFailure(accountResponse.body);
    expect(accountResponse.statusCode, 200);

    di.read(accountProvider.notifier).state = Account.fromJson(
      json.decode(accountResponse.body) as Map<String, dynamic>,
    );
  }

  @override
  @mustCallSuper
  Future<void> tearDownAll() async {
    try {
      final deleteResponse = await http.post(
        _createUri('delete'),
        body: json
            .encode(DeleteAccountPostModel(di.read(accountProvider).idToken)),
      );

      printOnFailure(deleteResponse.body);
      expect(deleteResponse.statusCode, 200);
    } finally {
      await super.tearDownAll();
    }
  }

  Uri _createUri(String method) => Uri.https(
        'identitytoolkit.googleapis.com',
        '/v1/accounts:$method',
        <String, String>{
          'key': ConfigSetup.apiKey,
        },
      );
}
