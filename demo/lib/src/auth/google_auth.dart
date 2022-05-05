import 'dart:io';

import 'package:flutter_data_demo/src/setup/defines.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oauth2/oauth2.dart';
import 'package:url_launcher/url_launcher.dart';

late final googleAuthProvider = Provider(
  (ref) => GoogleAuth(
    ref.watch(definesProvider),
  ),
);

class GoogleAuth {
  static final redirectUrl = Uri.parse('http://localhost:5000/__/auth/handler');

  static final _authorizationEndpoint =
      Uri.parse('https://accounts.google.com/o/oauth2/auth');
  static final _tokenEndpoint =
      Uri.parse('https://oauth2.googleapis.com/token');
  static const _scopes = ['openid'];

  final Defines _defines;

  GoogleAuth(this._defines);

  Future<Credentials> authorize() async {
    final grant = AuthorizationCodeGrant(
      _defines.googleClientId,
      _authorizationEndpoint,
      _tokenEndpoint,
      secret: _defines.googleClientSecret,
    );
    try {
      final authorizationUrl = grant.getAuthorizationUrl(
        redirectUrl,
        scopes: _scopes,
      );

      final responseUrlFuture = _listen(redirectUrl);
      await _redirect(authorizationUrl);
      final responseUrl = await responseUrlFuture;

      final client = await grant.handleAuthorizationResponse(
        responseUrl.queryParameters,
      );
      return client.credentials;
    } finally {
      grant.close();
    }
  }

  Future<void> _redirect(Uri authorizationUrl) async {
    await launchUrl(
      authorizationUrl,
      mode: LaunchMode.inAppWebView,
    );
  }

  Future<Uri> _listen(Uri redirectUrl) async {
    final server = await HttpServer.bind(redirectUrl.host, redirectUrl.port);
    try {
      await for (final request in server) {
        if (request.uri.path == redirectUrl.path) {
          request.response.writeln(
            "Authentication successful. You can close this window now",
          );
          await request.response.close();
          return request.uri;
        }
      }

      throw StateError('Server terminated without authentication');
    } finally {
      await server.close();
    }
  }
}
