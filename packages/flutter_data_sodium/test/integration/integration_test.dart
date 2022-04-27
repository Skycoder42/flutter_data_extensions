import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

import 'server/client_messages.dart';
import 'setup/setup.dart';

void main() {
  // ignore: unused_local_variable
  final setup = Setup()..call();

  test('test server', () async {
    final baseUrl = await setup.serverController.baseUrl;

    await setup.serverController
        .prepareHandler(HttpHandlerMessage(requestPath: '/test'));

    expect(
      get(baseUrl.resolve('test')),
      completion(predicate<Response>((r) => r.statusCode == HttpStatus.ok)),
    );
  });
}
