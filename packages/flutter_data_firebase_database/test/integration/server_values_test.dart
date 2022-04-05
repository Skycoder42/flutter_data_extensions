import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:test/test.dart';

import 'repositories/values_repository.dart';
import 'setup/account_setup.dart';
import 'setup/config_setup.dart';
import 'setup/database_setup.dart';
import 'setup/di_setup.dart';
import 'setup/repo_setup.dart';
import 'setup/setup.dart';

class ValuesRepositorySetup extends Setup
    with DiSetup, ConfigSetup, AccountSetup, DatabaseSetup, RepoSetup {
  late Repository<ValuesModel> repository;

  @override
  Future<void> setUpAll() async {
    await super.setUpAll();

    repository = di.read(valuesModelsRepositoryProvider);
  }

  @override
  Future<void> tearDownAll() async {
    try {
      await repository.clear();
      repository.dispose();
    } finally {
      await super.tearDownAll();
    }
  }
}

void main() {
  final setup = ValuesRepositorySetup()..call();

  group('server timestamp', () {
    Matcher isBetween(DateTime begin, DateTime end) => predicate<DateTime>(
          (d) => d.isAfter(begin) && d.isBefore(end),
          'is between $begin and $end',
        );

    test('creates timestamp with current server timestamp', () async {
      const id = 'timestamp-1';
      final model = ValuesModel(
        id: id,
        serverTimestamp: const ServerTimestamp(),
      );

      final before = DateTime.now().subtract(const Duration(seconds: 10));
      final saveResponse = await setup.repository.save(model);
      final after = DateTime.now().add(const Duration(seconds: 10));
      expect(saveResponse.serverTimestamp, isNotNull);
      expect(
        saveResponse.serverTimestamp!.dateTime,
        isBetween(before, after),
      );

      final getResponse = await setup.repository.findOne(id);
      expect(getResponse, isNotNull);
      expect(getResponse!.serverTimestamp, saveResponse.serverTimestamp);
    });

    test('creates timestamp from DateTime', () async {
      const id = 'timestamp-2';
      final dt = DateTime.utc(2000, 10, 4, 19, 33, 34, 123);
      final model = ValuesModel(
        id: id,
        serverTimestamp: ServerTimestamp.value(dt),
      );

      final saveResponse = await setup.repository.save(model);
      expect(saveResponse.serverTimestamp, isNotNull);
      expect(saveResponse.serverTimestamp!.dateTime, dt);

      final getResponse = await setup.repository.findOne(id);
      expect(getResponse, isNotNull);
      expect(getResponse!.serverTimestamp, saveResponse.serverTimestamp);
    });
  });

  group('server incrementable', () {
    test('create data from incrementable with increment', () async {
      const id = 'increment-1';
      final model = ValuesModel(
        id: id,
        serverIncrementable: const ServerIncrementable(10),
      );

      final saveResponse = await setup.repository.save(model);
      expect(saveResponse.serverIncrementable, isNotNull);
      expect(saveResponse.serverIncrementable!.value, 10);

      final getResponse = await setup.repository.findOne(id);
      expect(getResponse, isNotNull);
      expect(
        getResponse!.serverIncrementable,
        saveResponse.serverIncrementable,
      );
    });

    test('update data from incrementable with increment', () async {
      const id = 'increment-1';
      final model = ValuesModel(
        id: id,
        serverIncrementable: const ServerIncrementable(5),
      );

      final saveResponse = await setup.repository.save(model);
      expect(saveResponse.serverIncrementable, isNotNull);
      expect(saveResponse.serverIncrementable!.value, 15);

      final getResponse = await setup.repository.findOne(id);
      expect(getResponse, isNotNull);
      expect(
        getResponse!.serverIncrementable,
        saveResponse.serverIncrementable,
      );
    });

    test('creates incrementable from value', () async {
      const id = 'increment-2';
      final model = ValuesModel(
        id: id,
        serverIncrementable: const ServerIncrementable.value(23),
      );

      final saveResponse = await setup.repository.save(model);
      expect(saveResponse.serverIncrementable, isNotNull);
      expect(saveResponse.serverIncrementable!.value, 23);

      final getResponse = await setup.repository.findOne(id);
      expect(getResponse, isNotNull);
      expect(
        getResponse!.serverIncrementable,
        saveResponse.serverIncrementable,
      );
    });
  });
}
