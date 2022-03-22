// ignore_for_file: avoid_print

import 'package:flutter_data/flutter_data.dart';
import 'package:test/test.dart';

import 'repositories/test_repository.dart';
import 'setup/account_setup.dart';
import 'setup/config_setup.dart';
import 'setup/database_setup.dart';
import 'setup/di_setup.dart';
import 'setup/repo_setup.dart';
import 'setup/setup.dart';

class _SampleTestSetup extends Setup
    with DiSetup, ConfigSetup, AccountSetup, DatabaseSetup, RepoSetup {
  late Repository<TestModel> repository;

  @override
  Future<void> setUpAll() async {
    await super.setUpAll();

    repository = di.read(testModelsRepositoryProvider);
  }

  @override
  Future<void> tearDownAll() async {
    try {
      repository.dispose();
    } finally {
      await super.tearDownAll();
    }
  }
}

void main() {
  group('basic crud', () {
    const knownId = 'known-id';

    final setup = _SampleTestSetup()..call();

    Matcher _isTestModel(String name, {Matcher? id}) => isA<TestModel>()
        .having((model) => model.name, 'name', name)
        .having((model) => model.id, 'id', id ?? anything);

    test('returns empty list of entries by default', () async {
      final entries = await setup.repository.findAll(syncLocal: true);
      expect(entries, isEmpty);
    });

    test('creates new entries', () async {
      final model1 = TestModel(name: 'create_1');
      final model2 = TestModel(name: 'create_2');

      final createdModel1 = await setup.repository.save(model1);
      expect(createdModel1, _isTestModel(model1.name, id: isNotNull));
      expect(createdModel1.id, isNotEmpty);
      expect(createdModel1.name, model1.name);

      final createdModel2 = await setup.repository.save(model2);
      expect(createdModel2.id, isNotEmpty);
      expect(createdModel2.name, model2.name);

      expect(createdModel2.id, isNot(createdModel1.id));
    });

    test('can fetch recently created entries', () async {
      final entries = await setup.repository.findAll(syncLocal: true);

      expect(entries, hasLength(2));
      expect(
        entries,
        allOf(
          contains(_isTestModel('create_1', id: isNotNull)),
          contains(_isTestModel('create_2', id: isNotNull)),
        ),
      );
    });

    test('can create entry with known id', () async {
      final entry = TestModel(id: knownId, name: 'created_with_id');

      final createdEntry = await setup.repository.save(entry);

      expect(createdEntry, entry);
    });

    test('returns null for non existent find', () async {
      final entry = await setup.repository.findOne('invalid-id');

      expect(entry, isNull);
    });

    test('can find and update single entry with known id', () async {
      final entry = await setup.repository.findOne(knownId);

      expect(entry, isNotNull);
      expect(entry, _isTestModel('created_with_id', id: equals(knownId)));

      final modifiedEntry =
          await TestModel(name: 'updated_with_id', id: entry!.id)
              .was(entry)
              .save();

      expect(
        modifiedEntry,
        _isTestModel('updated_with_id', id: equals(knownId)),
      );
    });

    test('can delete entry and does not find it anymore', () async {
      final localEntry = await setup.repository.findOne(knownId, remote: false);

      expect(localEntry, isNotNull);
      await localEntry!.delete();

      final removedEntry = await setup.repository.findOne('know-id');
      expect(removedEntry, isNull);
    });
  });
}
