import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

part 'global_setup.g.dart';

@JsonSerializable()
class FirebaseAnonAccount {
  final String idToken;
  final String localId;

  const FirebaseAnonAccount({
    required this.idToken,
    required this.localId,
  });

  factory FirebaseAnonAccount.fromJson(Map<String, dynamic> json) =>
      _$FirebaseAnonAccountFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseAnonAccountToJson(this);
}

@JsonSerializable()
class _DeleteAccountPostModel {
  final String idToken;

  _DeleteAccountPostModel(this.idToken);

  // ignore: unused_element
  factory _DeleteAccountPostModel.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountPostModelToJson(this);
}

class AccountRef {
  late FirebaseAnonAccount _account;

  FirebaseAnonAccount get account => _account;
}

AccountRef setupFirebase() {
  final accountRef = AccountRef();

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

  setUpAll(() async {
    final accountResponse = await http.post(_createUri('signUp'));
    printOnFailure(accountResponse.body);
    expect(accountResponse.statusCode, 200);

    accountRef._account = FirebaseAnonAccount.fromJson(
      json.decode(accountResponse.body) as Map<String, dynamic>,
    );
  });

  tearDownAll(() async {
    final deleteResponse = await http.post(
      _createUri('delete'),
      body: json.encode(_DeleteAccountPostModel(accountRef.account.idToken)),
    );
    printOnFailure(deleteResponse.body);
    expect(deleteResponse.statusCode, 200);
  });

  return accountRef;
}
