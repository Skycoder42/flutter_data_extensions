import 'dart:io';

abstract class IntegrationTestConfig {
  static const _databaseHostKey = 'FIREBASE_DATABASE_HOST';
  static const _apiKeyKey = 'FIREBASE_API_KEY';

  IntegrationTestConfig._();

  static String get databaseHost =>
      Platform.environment[_databaseHostKey] ??
      const String.fromEnvironment(
        _databaseHostKey,
        defaultValue:
            // ignore: lines_longer_than_80_chars
            'flutter-data-extensions-default-rtdb.europe-west1.firebasedatabase.app',
      );

  static String get apiKey {
    final apiKey = Platform.environment[_apiKeyKey] ??
        const String.fromEnvironment(_apiKeyKey);
    if (apiKey.isEmpty) {
      throw ArgumentError(
        'environment or dart variable must be set',
        'FIREBASE_API_KEY',
      );
    }
    return apiKey;
  }
}
