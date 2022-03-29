import 'dart:async';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/src/firebase_database_adapter.dart';
import 'package:test/test.dart';

import 'repositories/test_repository.dart';
import 'setup/test_repository_setup.dart';

const bool _kIsWeb = identical(0, 0.0);

void main() {
  final setup = TestRepositorySetup()..call();

  group('streaming', () {
    late FirebaseDatabaseAdapter<TestModel> sut;

    setUp(() {
      sut = setup.repository.firebaseDatabaseAdapter;
    });

    Future<void> _put(TestModel model) async {
      final params = await sut.defaultParams;
      await sut.sendRequest<void>(
        // ignore: invalid_use_of_protected_member
        sut.baseUrl.asUri / sut.urlForSave(model.id, params) & params,
        method: sut.methodForSave(model.id, params),
        // ignore: invalid_use_of_protected_member
        headers: await sut.defaultHeaders,
        body: json.encode(sut.serialize(model)),
      );
      if (_kIsWeb) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }

    Future<void> _delete(String id) async {
      final params = await sut.defaultParams;
      await sut.sendRequest<void>(
        // ignore: invalid_use_of_protected_member
        sut.baseUrl.asUri / sut.urlForDelete(id, params) & params,
        // ignore: invalid_use_of_protected_member
        method: sut.methodForDelete(id, params),
        // ignore: invalid_use_of_protected_member
        headers: await sut.defaultHeaders,
      );
      if (_kIsWeb) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }

    test('[ASSERT] _put and _delete helpers do not update local state',
        () async {
      await _put(TestModel(name: '1', id: '_1'));
      expect(await sut.findAll(remote: false), isEmpty);
      await sut.save(TestModel(name: '1', id: '_1'), remote: false);

      await _delete('_1');
      expect(await sut.findAll(remote: false), isNotEmpty);
      await sut.delete('_1', remote: false);

      expect(await sut.findAll(), isEmpty);
    });

    group('streamAll', () {
      test('stream of new repository is initially empty', () {
        final stream = sut.streamAll(syncLocal: true);
        expect(stream, emits(isEmpty));
      });

      test('streams server events with remote changes', () async {
        // create initial data
        await _put(TestModel(id: '_1', name: 'model1'));
        await _put(TestModel(id: '_2', name: 'model2'));

        final stream = sut.streamAll();

        expect(
          stream,
          emitsInOrder(<dynamic>[
            emits([
              TestModel(id: '_1', name: 'model1'),
              TestModel(id: '_2', name: 'model2'),
            ]),
            emits([
              TestModel(id: '_1', name: 'model1'),
              TestModel(id: '_2', name: 'model2'),
              TestModel(id: '_3', name: 'model3'),
            ]),
            emits([
              TestModel(id: '_1', name: 'model1'),
              TestModel(id: '_2', name: 'model2_new'),
              TestModel(id: '_3', name: 'model3'),
            ]),
            emits([
              TestModel(id: '_2', name: 'model2_new'),
              TestModel(id: '_3', name: 'model3'),
            ]),
            emits([
              TestModel(id: '_2', name: 'model2_new'),
            ]),
            emits(isEmpty),
            emits(
              contains(
                isA<TestModel>()
                    .having((m) => m.name, 'name', 'posted')
                    .having((m) => m.id, 'id', allOf(isNotNull, isNotEmpty)),
              ),
            ),
            emits(isEmpty),
          ]),
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));

        await _put(TestModel(id: '_3', name: 'model3'));
        await _put(TestModel(id: '_2', name: 'model2_new'));
        await _delete('_1');
        await _delete('_3');
        await _delete('_2');
        final posted = await sut.save(TestModel(name: 'posted'));
        if (_kIsWeb) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        await sut.delete(posted);
      });

      test('stream events update the local repository', () async {
        // create initial data to overwrite
        await _put(TestModel(id: '_1', name: 'model1'));

        var stage = 0;
        await for (final event in sut.streamAll(syncLocal: true)) {
          final localState = await sut.findAll(remote: false);
          expect(localState, event);

          switch (stage++) {
            case 0:
              expect(event, hasLength(1));
              await _put(TestModel(id: '_2', name: 'model2'));
              continue;
            case 1:
              expect(event, hasLength(2));
              await _put(TestModel(id: '_3', name: 'model3'));
              continue;
            case 2:
              expect(event, hasLength(3));
              await _put(TestModel(id: '_1', name: 'model1_xxx'));
              continue;
            case 3:
              expect(event, hasLength(3));
              await _delete('_2');
              continue;
            case 4:
              expect(event, hasLength(2));
              await _delete('_3');
              continue;
            case 5:
              expect(event, hasLength(1));
              await _delete('_1');
              continue;
            default:
              expect(event, hasLength(0));
              break;
          }
          break;
        }
      });
    });
  });
}
