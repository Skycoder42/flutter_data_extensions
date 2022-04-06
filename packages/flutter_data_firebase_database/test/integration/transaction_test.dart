import 'package:dart_test_tools/dart_test_tools.dart';
// ignore: test_library_import
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'repositories/test_repository.dart';
import 'setup/test_repository_setup.dart';

void main() {
  final setup = TestRepositorySetup()..call();

  group('transactions', () {
    late FirebaseDatabaseAdapter<TestModel> sut;

    setUp(() {
      sut = setup.repository.firebaseDatabaseAdapter;
    });

    testData<Tuple2<TestModel?, TestModel?>>(
      'correctly runs simple non conflicting transactions',
      [
        const Tuple2(null, null),
        Tuple2(null, TestModel(id: '_1', name: 'new-data')),
        Tuple2(
          TestModel(id: '_1', name: 'new-data'),
          TestModel(id: '_1', name: 'updated-data'),
        ),
        Tuple2(
          TestModel(id: '_1', name: 'updated-data'),
          null,
        ),
      ],
      (fixture) async {
        final result = await sut.transaction(
          '_1',
          (data) {
            expect(data, fixture.item1);
            return fixture.item2;
          },
        );
        expect(result, fixture.item2);
      },
    );

    test('fails if data is modified between read and commit', () async {
      const testId = '_2';
      expect(
        () => sut.transaction(
          testId,
          (data) async {
            expect(data, isNull);
            await sut.save(TestModel(id: testId, name: 'external-modify'));
            return TestModel(id: testId, name: 'commit');
          },
        ),
        throwsA(isA<TransactionRejected>()),
      );
    });
  });
}
