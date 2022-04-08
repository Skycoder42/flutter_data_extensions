import 'dart:async';

import 'package:dart_test_tools/test.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/src/firebase_database_adapter.dart';
import 'package:flutter_data_firebase_database/src/transactions/transaction.dart';
import 'package:flutter_data_firebase_database/src/transactions/transaction_rejected.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../test_data_model.dart';

class MockFirebaseDatabaseAdapter extends Mock
    implements FirebaseDatabaseAdapter<TestDataModel> {}

class MockClient extends Mock implements Client {}

class MockResponse extends Mock implements Response {}

abstract class TransactionCallable<T extends DataModel<T>> {
  FutureOr<T?> call(String id, T? data);
}

class MockTransactionCallable extends Mock
    implements TransactionCallable<TestDataModel> {}

abstract class OnDataCallable<T> {
  FutureOr<T?> call(Object? data);
}

class MockOnDataCallable extends Mock implements OnDataCallable<TestDataModel> {
}

abstract class OnDataErrorCallable<T> {
  FutureOr<T?> call(DataException dataException);
}

class MockOnDataErrorCallable extends Mock
    implements OnDataErrorCallable<TestDataModel> {}

void main() {
  setUpAll(() {
    registerFallbackValue(TestDataModel());
    registerFallbackValue(Uri());
    registerFallbackValue(const DataException(''));
  });

  group('Transaction', () {
    const id = 'test-id';
    const params = {'a': 1, 'b': true};
    const headers = {'c': 'one', 'd': 'two'};
    final uri = Uri.http('example.com', '');

    final mockAdapter = MockFirebaseDatabaseAdapter();
    final mockClient = MockClient();
    final mockResponse = MockResponse();
    final mockTransaction = MockTransactionCallable();

    late Transaction<TestDataModel> sut;

    setUp(() {
      reset(mockAdapter);
      reset(mockClient);
      reset(mockResponse);
      reset(mockTransaction);

      when(() => mockAdapter.generateGetUri(any(), any())).thenReturnAsync(uri);
      when(() => mockAdapter.generateHeaders(any())).thenReturnAsync(headers);
      when(() => mockAdapter.deserialize(any()))
          .thenReturn(const DeserializedData([]));
      when(
        () => mockAdapter.save(
          any(),
          remote: any(named: 'remote'),
          params: any(named: 'params'),
          headers: any(named: 'headers'),
          onSuccess: any(named: 'onSuccess'),
          onError: any(named: 'onError'),
        ),
      ).thenReturnAsync(TestDataModel());
      when(
        () => mockAdapter.delete(
          any(),
          remote: any(named: 'remote'),
          params: any(named: 'params'),
          headers: any(named: 'headers'),
          onSuccess: any(named: 'onSuccess'),
          onError: any(named: 'onError'),
        ),
      ).thenReturnAsync(null);

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenReturnAsync(mockResponse);

      when(() => mockResponse.statusCode).thenReturn(HttpStatus.ok);
      when(() => mockResponse.headers).thenReturn(const {});
      when(() => mockResponse.body).thenReturn('null');

      when(() => mockTransaction.call(any(), any())).thenReturn(null);

      sut = Transaction(
        adapter: mockAdapter,
        httpClientFactory: () => mockClient,
      );
    });

    group('get remote data', () {
      test('sends get request with correct url and headers', () async {
        await sut(
          id,
          mockTransaction,
          params: params,
          headers: headers,
        );

        verifyInOrder([
          () => mockAdapter.generateGetUri(id, params),
          () => mockAdapter.generateHeaders(headers),
          () => mockClient.get(
                uri,
                headers: {
                  ...headers,
                  'X-Firebase-ETag': 'true',
                },
              ),
          () => mockClient.close(),
        ]);
        verifyNoMoreInteractions(mockClient);
      });

      test('calls transaction with null for non existent data', () async {
        await sut(id, mockTransaction);

        verifyInOrder([
          () => mockAdapter.deserialize(any(that: isNull)),
          () => mockTransaction.call(id, any(that: isNull)),
        ]);
      });

      test('calls transaction with data for existent data', () async {
        final testData = TestDataModel(id: id, data: 1);

        when(() => mockResponse.body).thenReturn('42');
        when(() => mockAdapter.deserialize(any()))
            .thenReturn(DeserializedData([testData]));

        await sut(id, mockTransaction);

        verifyInOrder([
          () => mockAdapter.deserialize(42),
          () => mockTransaction.call(id, testData),
        ]);
      });

      test('uses transformOne helper on remote data before deserializing',
          () async {
        final testData = TestDataModel(id: id, data: 11);

        when(() => mockResponse.body).thenReturn('{"data": 11}');
        when(() => mockAdapter.deserialize(any()))
            .thenReturn(DeserializedData([testData]));

        await sut(id, mockTransaction);

        verifyInOrder([
          () => mockAdapter.deserialize({'id': id, 'data': 11}),
          () => mockTransaction.call(id, testData),
        ]);
      });

      test('calls transaction with null for response with empty body',
          () async {
        when(() => mockResponse.statusCode).thenReturn(HttpStatus.noContent);
        when(() => mockResponse.body).thenReturn('');

        await sut(id, mockTransaction);

        verify(() => mockTransaction.call(id, any(that: isNull)));
        verifyNever(() => mockAdapter.deserialize(any()));
      });

      test('calls transaction with null for 404 errors by default', () async {
        when(() => mockResponse.statusCode).thenReturn(HttpStatus.notFound);

        await sut(id, mockTransaction);

        verify(() => mockTransaction.call(id, any(that: isNull)));
        verifyNever(() => mockAdapter.deserialize(any()));
      });

      test('calls onSuccess handler with deserialized data if given', () async {
        final testData1 = TestDataModel(id: id, data: 1);
        final testData2 = TestDataModel(id: id, data: 2);

        final mockOnSuccess = MockOnDataCallable();

        when(() => mockAdapter.deserialize(any()))
            .thenReturn(DeserializedData([testData1]));
        when(() => mockOnSuccess.call(any())).thenReturn(testData2);

        await sut(
          id,
          mockTransaction,
          onBeginSuccess: mockOnSuccess,
        );

        verifyInOrder([
          () => mockOnSuccess.call(testData1),
          () => mockTransaction.call(id, testData2),
        ]);
      });

      test('throws exception for failure status codes', () async {
        const errorBody = 'error-body';
        when(() => mockResponse.statusCode).thenReturn(HttpStatus.badRequest);
        when(() => mockResponse.body).thenReturn(errorBody);

        expect(
          () => sut(id, mockTransaction),
          throwsA(
            isA<DataException>()
                .having(
                  (e) => e.statusCode,
                  'statusCode',
                  HttpStatus.badRequest,
                )
                .having(
                  (e) => e.error,
                  'error',
                  errorBody,
                ),
          ),
        );
      });

      test('throws exception if reading throws', () async {
        when(() => mockAdapter.deserialize(any())).thenThrow(Exception());

        expect(
          () => sut(id, mockTransaction),
          throwsA(
            isA<DataException>()
                .having(
                  (e) => e.error,
                  'error',
                  isException,
                )
                .having(
                  (e) => e.stackTrace,
                  'stackTrace',
                  isNotNull,
                ),
          ),
        );
      });

      test(
          'returns data of onError handler if given and an exception is thrown',
          () async {
        final mockOnError = MockOnDataErrorCallable();
        final testData = TestDataModel(id: id, data: 1);

        when(() => mockAdapter.deserialize(any())).thenThrow(Exception());
        when(() => mockOnError.call(any())).thenReturn(testData);

        await sut(
          id,
          mockTransaction,
          onBeginError: mockOnError,
        );

        verifyInOrder([
          () => mockAdapter.deserialize(any()),
          () => mockOnError.call(
                any(
                  that: isA<DataException>()
                      .having(
                        (e) => e.error,
                        'error',
                        isException,
                      )
                      .having(
                        (e) => e.stackTrace,
                        'stackTrace',
                        isNotNull,
                      ),
                ),
              ),
          () => mockTransaction.call(id, testData),
        ]);
      });
    });

    group('commit transaction', () {
      group('with non null data', () {
        test('calls adapter.save with transaction model and etag header',
            () async {
          const eTag = 'e-tag';
          final testData = TestDataModel(id: id, data: 1);

          // header should be found case insensitive
          when(() => mockResponse.headers).thenReturn({'EtAg': eTag});
          when(() => mockTransaction.call(any(), any())).thenReturn(testData);
          when(
            () => mockAdapter.save(
              any(),
              remote: any(named: 'remote'),
              params: any(named: 'params'),
              headers: any(named: 'headers'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            ),
          ).thenReturnAsync(testData);

          final result = await sut(id, mockTransaction);

          expect(result, testData);

          verify(
            () => mockAdapter.save(
              testData,
              remote: true,
              headers: {'if-match': eTag},
              onError: any(named: 'onError'),
            ),
          );
        });

        test(
            'calls adapter.save with transaction model and null etag '
            'if headers did not contain etag', () async {
          final testData = TestDataModel(id: id, data: 1);

          when(() => mockTransaction.call(any(), any())).thenReturn(testData);

          await sut(id, mockTransaction);

          verify(
            () => mockAdapter.save(
              testData,
              remote: true,
              headers: {'if-match': 'null_etag'},
              onError: any(named: 'onError'),
            ),
          );
        });

        test('throws transaction rejected if updated model has different id',
            () async {
          final testData = TestDataModel(id: 'another-id', data: 1);

          when(() => mockTransaction.call(any(), any())).thenReturn(testData);

          await expectLater(
            () => sut.call(id, mockTransaction),
            throwsA(isA<TransactionInvalid>()),
          );

          verifyNever(
            () => mockAdapter.save(
              any(),
              remote: true,
              headers: any(named: 'headers'),
              onError: any(named: 'onError'),
            ),
          );
        });

        test(
          'default onError handler transforms 412 errors and rethrows others',
          () async {
            final testData = TestDataModel(id: id, data: 1);

            when(() => mockTransaction.call(any(), any())).thenReturn(testData);

            await sut(id, mockTransaction);

            final onError = verify(
              () => mockAdapter.save(
                testData,
                remote: true,
                headers: any(named: 'headers'),
                onError: captureAny(named: 'onError'),
              ),
            ).captured.cast<OnDataError<TestDataModel>>().single;

            const anyError = DataException('error');
            expect(() => onError(anyError), throwsA(anyError));
            expect(
              () => onError(const DataException('', statusCode: 412)),
              throwsA(isA<TransactionRejected>()),
            );
          },
          onPlatform: <String, dynamic>{
            'js': const Skip('Cannot test internal methods in JS')
          },
        );

        test('calls adapter.save with custom parameters', () async {
          final mockOnSuccess = MockOnDataCallable();
          final mockOnError = MockOnDataErrorCallable();
          final testData = TestDataModel(id: id, data: 1);

          when(() => mockTransaction.call(any(), any())).thenReturn(testData);

          await sut(
            id,
            mockTransaction,
            params: params,
            headers: headers,
            onCommitSuccess: mockOnSuccess,
            onCommitError: mockOnError,
          );

          verify(
            () => mockAdapter.save(
              testData,
              remote: true,
              params: params,
              headers: {...headers, 'if-match': 'null_etag'},
              onSuccess: mockOnSuccess,
              onError: mockOnError,
            ),
          );
        });
      });

      group('with null data', () {
        test('calls adapter.delete with etag header', () async {
          const eTag = 'e-tag';

          when(() => mockResponse.headers).thenReturn({'etAG': eTag});

          final result = await sut(id, mockTransaction);

          expect(result, isNull);

          verify(
            () => mockAdapter.delete(
              id,
              remote: true,
              headers: {'if-match': eTag},
              onError: any(named: 'onError'),
            ),
          );
        });

        test(
            'calls adapter.delete with null etag '
            'if headers did not contain etag', () async {
          await sut(id, mockTransaction);

          verify(
            () => mockAdapter.delete(
              id,
              remote: true,
              headers: {'if-match': 'null_etag'},
              onError: any(named: 'onError'),
            ),
          );
        });

        test(
          'default onError handler transforms 412 errors and rethrows others',
          () async {
            await sut(id, mockTransaction);

            final onError = verify(
              () => mockAdapter.delete(
                id,
                remote: true,
                headers: any(named: 'headers'),
                onError: captureAny(named: 'onError'),
              ),
            ).captured.cast<OnDataError<TestDataModel>>().single;

            const anyError = DataException('error');
            expect(() => onError(anyError), throwsA(anyError));
            expect(
              () => onError(const DataException('', statusCode: 412)),
              throwsA(isA<TransactionRejected>()),
            );
          },
          onPlatform: <String, dynamic>{
            'js': const Skip('Cannot test internal methods in JS')
          },
        );

        test('calls adapter.delete with custom parameters', () async {
          final mockOnSuccess = MockOnDataCallable();
          final mockOnError = MockOnDataErrorCallable();

          await sut(
            id,
            mockTransaction,
            params: params,
            headers: headers,
            onCommitSuccess: mockOnSuccess,
            onCommitError: mockOnError,
          );

          verify(
            () => mockAdapter.delete(
              id,
              remote: true,
              params: params,
              headers: {...headers, 'if-match': 'null_etag'},
              onSuccess: mockOnSuccess,
              onError: mockOnError,
            ),
          );
        });
      });
    });
  });
}
