import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'repositories/test_repository.dart';
import 'setup/http_setup.dart';
import 'setup/setup.dart';

void main() {
  final clock = Clock.fixed(DateTime(2022));
  final masterKey = Uint8List.fromList(List.filled(32, 0));

  // ignore: unused_local_variable
  final setup = Setup()..call(masterKey, clock);

  late Repository<TestModel> sut;

  setUp(() {
    sut = setup.testDataRepository;
  });

  group('save', () {
    test('without id sends encrypted data without id or ad', () async {
      const id = 'id';
      setup.prepareHandler((request) {
        expect(request.method, 'POST');
        expect(request.url.path, '/testModels');
        expect(
          request.jsonBody,
          allOf(
            containsPair('id', isNull),
            containsPair('cipherText', allOf(isA<String>(), hasLength(28))),
            containsPair('mac', allOf(isA<String>(), hasLength(24))),
            containsPair('nonce', allOf(isA<String>(), hasLength(32))),
            containsPair('hasAd', isFalse),
            containsPair('keyId', 633),
          ),
        );

        return jsonResponse(<String, dynamic>{
          ...request.jsonBody! as Map<String, dynamic>,
          'id': id,
        });
      });

      final testModel = TestModel(name: 'test-name');
      expect(
        sut.save(testModel),
        completion(TestModel(id: id, name: testModel.name)),
      );
    });

    test('fails if response data is invalid', () async {
      setup.prepareHandler(
        (request) => jsonResponse(<String, dynamic>{
          ...request.jsonBody! as Map<String, dynamic>,
          'mac': 'ueIxIhJLzgbT0Payhinecg==',
        }),
      );

      final testModel = TestModel(name: 'test-name');
      expect(
        sut.save(testModel),
        throwsA(isA<SodiumException>()),
      );
    });

    test('without id fails if response data has ad indicator', () async {
      const id = 'id';
      setup.prepareHandler(
        (request) => jsonResponse(<String, dynamic>{
          ...request.jsonBody! as Map<String, dynamic>,
          'id': id,
          'hasAd': true,
        }),
      );

      final testModel = TestModel(name: 'test-name');
      expect(
        sut.save(testModel),
        throwsA(isA<SodiumException>()),
      );
    });

    test('fails if response uses wrong key id', () async {
      setup.prepareHandler(
        (request) => jsonResponse(<String, dynamic>{
          ...request.jsonBody! as Map<String, dynamic>,
          'keyId': 42,
        }),
      );

      final testModel = TestModel(name: 'test-name');
      expect(
        sut.save(testModel),
        throwsA(isA<SodiumException>()),
      );
    });

    test('with id sends encrypted data with id and ad', () async {
      const id = 'id';
      setup.prepareHandler((request) {
        expect(request.method, 'PATCH');
        expect(request.url.path, '/testModels/$id');
        expect(
          request.jsonBody,
          allOf(
            containsPair('id', id),
            containsPair('cipherText', allOf(isA<String>(), hasLength(28))),
            containsPair('mac', allOf(isA<String>(), hasLength(24))),
            containsPair('nonce', allOf(isA<String>(), hasLength(32))),
            containsPair('hasAd', isTrue),
            containsPair('keyId', 633),
          ),
        );

        return jsonResponse(request.jsonBody);
      });

      final testModel = TestModel(id: id, name: 'test-name');
      expect(
        sut.save(testModel),
        completion(testModel),
      );
    });

    test('with id fails if response data is missing ad indicator', () async {
      const id = 'id';
      setup.prepareHandler(
        (request) => jsonResponse(<String, dynamic>{
          ...request.jsonBody! as Map<String, dynamic>,
          'hasAd': false,
        }),
      );

      final testModel = TestModel(id: id, name: 'test-name');
      expect(
        sut.save(testModel),
        throwsA(isA<SodiumException>()),
      );
    });
  });

  group('find', () {
    test('all returns empty list by default', () async {
      setup.prepareHandler((request) {
        expect(request.method, 'GET');
        expect(request.url.path, '/testModels');
        expect(request.body, isEmpty);
        return jsonResponse(const <Object>[]);
      });

      expect(
        sut.findAll(),
        completion(isEmpty),
      );
    });

    test('all can decrypt encrypted remote data', () async {
      const id = 'test-id';
      late final Map<String, dynamic> requestJson;
      setup
        ..prepareHandler((request) {
          expect(request.method, 'POST');
          requestJson = request.jsonBody! as Map<String, dynamic>;
          return jsonResponse(null);
        })
        ..prepareHandler((request) {
          expect(request.method, 'GET');
          return jsonResponse([
            <String, dynamic>{
              ...requestJson,
              'id': id,
            }
          ]);
        });

      final testModel = TestModel(name: 'test-model');
      await sut.save(testModel);

      final result = await sut.findAll(syncLocal: true);
      expect(result, hasLength(1));
      expect(result, contains(TestModel(id: id, name: testModel.name)));
    });

    test('one returns null by default', () async {
      const id = 'id';
      setup.prepareHandler((request) {
        expect(request.method, 'GET');
        expect(request.url.path, '/testModels/$id');
        expect(request.body, isEmpty);
        return jsonResponse(null);
      });

      expect(
        sut.findOne(id),
        completion(isNull),
      );
    });

    test('one can decrypt encrypted remote data', () async {
      const id = 'test-id';
      late final Map<String, dynamic> requestJson;
      setup
        ..prepareHandler((request) {
          expect(request.method, 'PATCH');
          requestJson = request.jsonBody! as Map<String, dynamic>;
          return jsonResponse(null);
        })
        ..prepareHandler((request) {
          expect(request.method, 'GET');
          return jsonResponse(requestJson);
        });

      final testModel = TestModel(id: id, name: 'test-model');
      await sut.save(testModel);

      expect(
        sut.findOne(id),
        completion(testModel),
      );
    });
  });
}
