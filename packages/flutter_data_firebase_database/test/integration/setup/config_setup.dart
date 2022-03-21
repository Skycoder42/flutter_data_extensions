import 'package:dart_test_tools/dart_test_tools.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';

import 'di_setup.dart';

mixin ConfigSetup on DiSetup {
  static late final databaseHostProvider = StateProvider(
    (ref) =>
        // ignore: lines_longer_than_80_chars
        'flutter-data-extensions-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static late final apiKeyProvider = StateProvider((ref) => '');

  @override
  @mustCallSuper
  Future<void> setUpAll() async {
    await super.setUpAll();

    final env = await TestEnv.load();

    // read api key
    final apiKey = env['FIREBASE_API_KEY'];
    if (apiKey == null) {
      throw ArgumentError(
        'environment or dart variable must be set',
        'FIREBASE_API_KEY',
      );
    }
    di.read(apiKeyProvider.notifier).state = apiKey;

    // read host
    final databaseHost = env['FIREBASE_DATABASE_HOST'];
    if (databaseHost != null) {
      di.read(databaseHostProvider.notifier).state = databaseHost;
    }
  }
}
