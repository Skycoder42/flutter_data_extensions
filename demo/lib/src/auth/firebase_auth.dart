import 'dart:convert';
import 'dart:io';

import 'package:flutter_data_demo/src/auth/firebase_account.dart';
import 'package:flutter_data_demo/src/auth/google_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;

import '../setup/defines.dart';

late final firebaseAuthProvider = Provider(
  (ref) => FirebaseAuth(
    ref.watch(definesProvider),
  ),
);

class FirebaseAuth {
  final Defines _defines;

  FirebaseAuth(this._defines);

  Future<FirebaseAccount> loginWithGoogle(Credentials googleCredentials) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.https(
          'identitytoolkit.googleapis.com',
          '/v1/accounts:signInWithIdp',
          {
            'key': _defines.apiKey,
          },
        ),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.toString(),
        },
        body: json.encode({
          'requestUri': GoogleAuth.redirectUrl.toString(),
          'postBody': Uri(queryParameters: {
            'id_token': '${googleCredentials.idToken}',
            'providerId': 'google.com',
          }).query,
          'returnSecureToken': true,
          'returnIdpCredential': true,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Login failed with status code ${response.statusCode} '
          'and body: ${response.body}',
        );
      }

      return FirebaseAccount.fromJson(json.decode(response.body));
    } finally {
      client.close();
    }
  }
}
