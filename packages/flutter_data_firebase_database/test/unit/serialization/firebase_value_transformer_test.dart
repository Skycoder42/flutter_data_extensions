import 'dart:convert';

import 'package:flutter_data_firebase_database/src/serialization/firebase_value_transformer.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseValueTransformer', () {
    group('transformAll', () {
      test('returns non maps as is', () {
        final data = [1, 2, 3];

        final result = FirebaseValueTransformer.transformAll(data);

        expect(result, same(data));
      });

      test('keeps values of non map entries as is', () {
        final data = {
          'key1': 1,
          'key2': 1.1,
          'key3': false,
          'key5': 'test',
          'key6': [1],
        };

        final result = FirebaseValueTransformer.transformAll(data);

        expect(result, data.values);
      });

      test('adds key of entry as id in value map', () {
        final data = {
          'key1': {'a': 1, 'b': 2},
          'key2': {'c': 3, 'id': 4},
        };

        final result = FirebaseValueTransformer.transformAll(data);

        expect(result, [
          {'id': 'key1', 'a': 1, 'b': 2},
          {'id': 'key2', 'c': 3},
        ]);
      });
    });

    group('transformOne', () {
      const id = 'test-id';

      test('returns non maps as is', () {
        final data = [1, 2, 3];

        final result = FirebaseValueTransformer.transformOne(data, id);

        expect(result, same(data));
      });

      test('adds id to map data', () {
        final data = {'a': 1, 'b': 2};

        final result = FirebaseValueTransformer.transformOne(data, id);

        expect(result, {'id': id, 'a': 1, 'b': 2});
      });

      test('replaces id to map data', () {
        final data = {'id': 4, 'c': 3};

        final result = FirebaseValueTransformer.transformOne(data, id);

        expect(result, {'id': id, 'c': 3});
      });
    });

    group('transformSaveCreate', () {
      final originalData = {'id': null, 'a': 1, 'b': 2};
      final originalDataString = json.encode(originalData);

      test('returns non name data as is', () {
        final data = {
          ...originalData,
          'c': '3',
        };

        final result = FirebaseValueTransformer.transformCreated(
          data,
          originalDataString,
        );

        expect(result, same(data));
      });

      test('enriches original data with id of name only data', () {
        const id = 'test-id';
        final data = {'name': id};

        final result = FirebaseValueTransformer.transformCreated(
          data,
          originalDataString,
        );
        expect(result, {...originalData, 'id': id});
      });
    });
  });
}
