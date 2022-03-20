import 'package:flutter_data/flutter_data.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'account_setup.dart';
import 'config.dart';

mixin DatabaseSetup on AccountSetup {
  static late final _incrementProvider = StateProvider((ref) => 0);
  static late final databasePathProvider = StateProvider(
    (ref) => '',
  );

  @override
  @mustCallSuper
  Future<void> setUp() async {
    await super.setUp();

    final increment = di.read(_incrementProvider.notifier).state++;
    final account = di.read(AccountSetup.accountProvider);
    di.read(databasePathProvider.notifier).state =
        '/${account.localId}/_$increment';
  }

  @override
  @mustCallSuper
  Future<void> tearDownAll() async {
    try {
      final account = di.read(AccountSetup.accountProvider);
      final response = await http.delete(
        Uri.https(
          IntegrationTestConfig.databaseHost,
          '/${account.localId}.json',
          <String, String>{
            'auth': account.idToken,
          },
        ),
      );

      printOnFailure(response.body);
      expect(response.statusCode, 200);
    } finally {
      await super.tearDownAll();
    }
  }
}
