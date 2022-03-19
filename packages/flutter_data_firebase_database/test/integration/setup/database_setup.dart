import 'dart:async';

import 'package:flutter_data/flutter_data.dart';
import 'package:http/http.dart' as http;

import 'account_setup.dart';
import 'setup.dart';

class DatabaseSetup extends Setup {
  static late final _incrementProvider = StateProvider((ref) => 0);
  static late final databasePathProvider = StateProvider(
    (ref) => '',
  );

  const DatabaseSetup(ProviderContainer di) : super(di);

  @override
  FutureOr<void> setUp() {
    final increment = di.read(_incrementProvider.notifier).state++;
    final account = di.read(AccountSetup.accountProvider);
    di.read(databasePathProvider.notifier).state =
        '/${account.localId}/_$increment';
  }

  @override
  FutureOr<void> tearDownAll() async {
    final account = di.read(AccountSetup.accountProvider);
    final response = await http.delete(
      Uri.https(
        'flutter-data-extensions-default-rtdb.europe-west1.firebasedatabase.app',
        '/${account.localId}.json',
        <String, String>{
          'auth': account.idToken,
        },
      ),
    );

    if (response.statusCode != 200) {
      // ignore: avoid_print
      print('WARNING: Failed to delete account database with result:');
      // ignore: avoid_print
      print(response.body);
    }
  }
}
