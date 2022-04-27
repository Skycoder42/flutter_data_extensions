import 'dart:typed_data';

import 'package:test/test.dart';

import 'server/client_messages.dart';
import 'setup/setup.dart';

void main() {
  final masterKey = Uint8List.fromList(List.filled(32, 0));

  // ignore: unused_local_variable
  final setup = Setup()..call(masterKey);

  test('get returns empty list by default', () async {
    await setup.serverController.prepareHandler(
      HttpHandlerMessage(
        requestPath: '/testModels',
      ),
    );

    expect(
      setup.testDataRepository.findAll(),
      completion(isEmpty),
    );
  });
}
