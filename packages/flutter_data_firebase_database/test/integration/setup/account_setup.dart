import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_data/flutter_data.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'models/account.dart';
import 'setup.dart';

class AccountSetup extends Setup {
  static late final accountProvider = StateProvider(
    (ref) => const Account(idToken: '', localId: ''),
  );

  final ProviderContainer di;

  AccountSetup(this.di);

  @override
  FutureOr<void> setUpAll() async {
    final accountResponse = await http.post(_createUri('signUp'));
    printOnFailure(accountResponse.body);
    expect(accountResponse.statusCode, 200);

    di.read(accountProvider.notifier).state = Account.fromJson(
      json.decode(accountResponse.body) as Map<String, dynamic>,
    );
  }

  @override
  FutureOr<void> tearDownAll() async {
    final deleteResponse = await http.post(
      _createUri('delete'),
      body:
          json.encode(DeleteAccountPostModel(di.read(accountProvider).idToken)),
    );
    printOnFailure(deleteResponse.body);
    expect(deleteResponse.statusCode, 200);
  }

  Uri _createUri(String method) {
    final apiKey = Platform.environment['FIREBASE_API_KEY'];
    expect(
      apiKey,
      allOf(isNotNull, isNotEmpty),
      reason: 'FIREBASE_API_KEY environment variable must be set',
    );
    return Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/accounts:$method',
      <String, String>{'key': apiKey!},
    );
  }
}
