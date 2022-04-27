import 'package:flutter_data/flutter_data.dart';
import 'package:test/test.dart';

import '../repositories/test_adapter.dart';
import '../server/server_controller.dart';
import 'sodium_setup_vm.dart' if (dart.library.js) 'sodium_setup_js.dart';

class Setup with SodiumSetup {
  late ProviderContainer providerContainer;
  late ServerController serverController;

  void call() {
    setUp(() async {
      serverController = ServerController();

      providerContainer = ProviderContainer(
        overrides: [
          TestAdapter.sodiumProvider.overrideWithValue(await loadSodium()),
          TestAdapter.baseUrlProvider
              .overrideWithValue(await serverController.baseUrl),
        ],
      );
    });

    tearDown(() {
      providerContainer.dispose();
    });
  }
}
