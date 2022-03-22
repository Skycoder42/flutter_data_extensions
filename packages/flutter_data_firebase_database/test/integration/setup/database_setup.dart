import 'package:flutter_data/flutter_data.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'account_setup.dart';
import 'config_setup.dart';

mixin DatabaseSetup on AccountSetup {
  static late final databasePathProvider = StateProvider(
    (ref) => '',
  );

  @override
  @mustCallSuper
  Future<void> setUpAll() async {
    await super.setUpAll();

    final account = di.read(AccountSetup.accountProvider);
    di.read(databasePathProvider.notifier).state = '/${account.localId}';
  }

  @override
  @mustCallSuper
  Future<void> tearDownAll() async {
    try {
      final account = di.read(AccountSetup.accountProvider);
      final response = await http.delete(
        Uri.https(
          di.read(ConfigSetup.databaseHostProvider),
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
