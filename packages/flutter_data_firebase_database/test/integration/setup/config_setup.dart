import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:meta/meta.dart';

import 'setup.dart';

mixin ConfigSetup on Setup {
  static String get databaseHost =>
      dotenv.env['FIREBASE_DATABASE_HOST'] ??
      'flutter-data-extensions-default-rtdb.europe-west1.firebasedatabase.app';

  static String get apiKey {
    final apiKey = dotenv.env['FIREBASE_API_KEY'];
    if (apiKey == null) {
      throw ArgumentError(
        'environment or dart variable must be set',
        'FIREBASE_API_KEY',
      );
    }
    return apiKey;
  }

  @override
  @mustCallSuper
  Future<void> setUpAll() async {
    await super.setUpAll();

    dotenv.load();
  }
}
