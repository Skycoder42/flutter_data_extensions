// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:dart_test_tools/dart_test_tools.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/src/firebase_database_adapter.dart';
import 'package:flutter_data_firebase_database/src/queries/filter.dart';
import 'package:flutter_data_firebase_database/src/queries/format_mode.dart';
import 'package:flutter_data_firebase_database/src/queries/request_config.dart';
import 'package:flutter_data_firebase_database/src/queries/timeout.dart';
import 'package:flutter_data_firebase_database/src/queries/write_size_limit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart' hide Timeout;
import 'package:tuple/tuple.dart';

import 'test_data_model.dart';

const testIdToken = 'id-token';

abstract class OnDataCallable<T> {
  FutureOr<T?> call(Object? data);
}

class MockOnDataCallable<T> extends Mock implements OnDataCallable<T> {}

abstract class OnDataErrorCallable<T> {
  FutureOr<T?> call(DataException dataException);
}

class MockOnDataErrorCallable<T> extends Mock
    implements OnDataErrorCallable<T> {}

class MockRemoteAdapter extends Mock implements RemoteAdapter<TestDataModel> {}

class ProxyRemoteAdapter implements RemoteAdapter<TestDataModel> {
  final MockRemoteAdapter mockRemoteAdapter;

  ProxyRemoteAdapter(this.mockRemoteAdapter);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      mockRemoteAdapter.noSuchMethod(invocation);
}

class SutRemoteAdapter extends ProxyRemoteAdapter with FirebaseDatabaseAdapter {
  @override
  String idToken = testIdToken;

  @override
  RequestConfig? defaultRequestConfig;

  @override
  Filter? defaultQueryFilter;

  SutRemoteAdapter(MockRemoteAdapter mockRemoteAdapter)
      : super(mockRemoteAdapter);
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(DataRequestMethod.HEAD);
    registerFallbackValue(DataRequestType.adhoc);
  });

  group('FirebaseDatabaseAdapter', () {
    final mockRemoteAdapter = MockRemoteAdapter();

    late SutRemoteAdapter sut;

    setUp(() {
      reset(mockRemoteAdapter);

      sut = SutRemoteAdapter(mockRemoteAdapter);
    });

    // TODO test streamAll
    // TODO test streamOne
    // TODO test streamTransaction

    group('overrides', () {
      const testId = 'test-id';
      const testUrlPath = '/path/to/resource';
      const testParams = {'a': '1', 'b': 'true'};

      group('defaultParams', () {
        test('always adds auth token to params ', () async {
          when(() => mockRemoteAdapter.defaultParams).thenReturn(testParams);

          expect(await sut.defaultParams, {...testParams, 'auth': testIdToken});

          verify(() => mockRemoteAdapter.defaultParams);
        });

        test('adds request config to params if given ', () async {
          when(() => mockRemoteAdapter.defaultParams).thenReturn(testParams);
          const requestConfig = RequestConfig(
            format: FormatMode.export,
            shallow: false,
            timeout: Timeout.s(1),
            writeSizeLimit: WriteSizeLimit.medium,
          );
          sut.defaultRequestConfig = requestConfig;

          expect(await sut.defaultParams, {
            ...testParams,
            ...requestConfig.asParams,
            'auth': testIdToken,
          });

          verify(() => mockRemoteAdapter.defaultParams);
        });
      });

      test('urlForFindAll adds json to URL', () {
        when(() => mockRemoteAdapter.urlForFindAll(any()))
            .thenReturn(testUrlPath);

        final result = sut.urlForFindAll(testParams);
        expect(result, '$testUrlPath.json');

        verify(() => mockRemoteAdapter.urlForFindAll(testParams));
      });

      test('urlForFindOne adds json to URL', () {
        when(() => mockRemoteAdapter.urlForFindOne(any<dynamic>(), any()))
            .thenReturn(testUrlPath);

        final result = sut.urlForFindOne(testId, testParams);
        expect(result, '$testUrlPath.json');

        verify(() => mockRemoteAdapter.urlForFindOne(testId, testParams));
      });

      test('urlForSave adds json to URL', () {
        when(() => mockRemoteAdapter.urlForSave(any<dynamic>(), any()))
            .thenReturn(testUrlPath);

        final result = sut.urlForSave(testId, testParams);
        expect(result, '$testUrlPath.json');

        verify(() => mockRemoteAdapter.urlForSave(testId, testParams));
      });

      test('urlForDelete adds json to URL', () {
        when(() => mockRemoteAdapter.urlForDelete(any<dynamic>(), any()))
            .thenReturn(testUrlPath);

        final result = sut.urlForDelete(testId, testParams);
        expect(result, '$testUrlPath.json');

        verify(() => mockRemoteAdapter.urlForDelete(testId, testParams));
      });

      testData<Tuple2<String?, DataRequestMethod>>(
        'methodForSave returns correct method for id',
        const [
          Tuple2(null, DataRequestMethod.POST),
          Tuple2(testId, DataRequestMethod.PUT),
        ],
        (fixture) {
          final method = sut.methodForSave(fixture.item1, testParams);

          expect(method, fixture.item2);

          verifyNever(
            () => mockRemoteAdapter.methodForSave(any<dynamic>(), any()),
          );
        },
      );

      group('sendRequest', () {
        final testUri = Uri.http('localhost', '/test');
        const testHeaders = {'h1': 'a', 'h2': 'b'};
        const testKey = 'test#key';
        const testBody = '"test.body"';

        final testResult = TestDataModel(id: 'R', data: 10);

        final mockOnSuccess = MockOnDataCallable<TestDataModel>();
        final mockOnError = MockOnDataErrorCallable<TestDataModel>();

        setUp(() {
          reset(mockOnSuccess);
          reset(mockOnError);

          when(
            () => mockRemoteAdapter.sendRequest<TestDataModel>(
              any(),
              method: any(named: 'method'),
              headers: any(named: 'headers'),
              omitDefaultParams: any(named: 'omitDefaultParams'),
              requestType: any(named: 'requestType'),
              key: any(named: 'key'),
              body: any(named: 'body'),
              onSuccess: any(named: 'onSuccess'),
              onError: any(named: 'onError'),
            ),
          ).thenReturn(testResult);
        });

        group('findAll', () {
          test(
            'uses transformAll to transform received data',
            () async {
              when(() => mockOnSuccess.call(any())).thenReturn(testResult);

              final result = await sut.sendRequest<TestDataModel>(
                testUri,
                method: DataRequestMethod.GET,
                headers: testHeaders,
                omitDefaultParams: true,
                requestType: DataRequestType.findAll,
                key: testKey,
                body: testBody,
                onSuccess: mockOnSuccess,
                onError: mockOnError,
              );

              expect(result, testResult);
              final onSuccess = verify(
                () => mockRemoteAdapter.sendRequest<TestDataModel>(
                  testUri,
                  method: DataRequestMethod.GET,
                  headers: testHeaders,
                  omitDefaultParams: true,
                  requestType: DataRequestType.findAll,
                  key: testKey,
                  body: testBody,
                  onSuccess: captureAny(named: 'onSuccess'),
                  onError: mockOnError,
                ),
              ).captured.cast<OnData<TestDataModel>>().single;

              final onSuccessResult = onSuccess({
                'a': {'data': 1},
                'b': {'data': 2},
              });
              expect(onSuccessResult, testResult);

              verify(
                () => mockOnSuccess.call([
                  {'id': 'a', 'data': 1},
                  {'id': 'b', 'data': 2},
                ]),
              );
            },
            onPlatform: <String, dynamic>{
              'js': const Skip('Cannot test internal methods in JS')
            },
          );

          test('adds default query filter if not null', () async {
            final filter = Filter.key().build();
            sut.defaultQueryFilter = filter;

            await sut.sendRequest<TestDataModel>(
              testUri,
              requestType: DataRequestType.findAll,
              onSuccess: mockOnSuccess,
            );

            verify(
              () => mockRemoteAdapter.sendRequest<TestDataModel>(
                testUri & filter,
                method: DataRequestMethod.GET,
                omitDefaultParams: false,
                requestType: DataRequestType.findAll,
                onSuccess: any(named: 'onSuccess'),
              ),
            );
          });

          test('does not add default query if custom query is set', () async {
            final filter = Filter.value<int>().build();
            sut.defaultQueryFilter = Filter.key().build();

            await sut.sendRequest<TestDataModel>(
              testUri & filter,
              requestType: DataRequestType.findAll,
              onSuccess: mockOnSuccess,
            );

            verify(
              () => mockRemoteAdapter.sendRequest<TestDataModel>(
                testUri & filter,
                method: DataRequestMethod.GET,
                omitDefaultParams: false,
                requestType: DataRequestType.findAll,
                onSuccess: any(named: 'onSuccess'),
              ),
            );
          });
        });

        group('findOne', () {
          final testUriWithId = testUri / testId;

          test(
            'uses transformOne to transform received data',
            () async {
              when(() => mockOnSuccess.call(any())).thenReturn(testResult);

              final result = await sut.sendRequest<TestDataModel>(
                testUriWithId,
                method: DataRequestMethod.GET,
                headers: testHeaders,
                omitDefaultParams: true,
                requestType: DataRequestType.findOne,
                key: testKey,
                body: testBody,
                onSuccess: mockOnSuccess,
                onError: mockOnError,
              );

              expect(result, testResult);
              final onSuccess = verify(
                () => mockRemoteAdapter.sendRequest<TestDataModel>(
                  testUriWithId,
                  method: DataRequestMethod.GET,
                  headers: testHeaders,
                  omitDefaultParams: true,
                  requestType: DataRequestType.findOne,
                  key: testKey,
                  body: testBody,
                  onSuccess: captureAny(named: 'onSuccess'),
                  onError: mockOnError,
                ),
              ).captured.cast<OnData<TestDataModel>>().single;

              final onSuccessResult = onSuccess({'data': 1});
              expect(onSuccessResult, testResult);

              verify(
                () => mockOnSuccess.call({'id': testId, 'data': 1}),
              );
            },
            onPlatform: <String, dynamic>{
              'js': const Skip('Cannot test internal methods in JS')
            },
          );

          test('adds default query filter if not null', () async {
            final filter = Filter.key().build();
            sut.defaultQueryFilter = filter;

            await sut.sendRequest<TestDataModel>(
              testUriWithId,
              requestType: DataRequestType.findOne,
              onSuccess: mockOnSuccess,
            );

            verify(
              () => mockRemoteAdapter.sendRequest<TestDataModel>(
                testUriWithId & filter,
                method: DataRequestMethod.GET,
                omitDefaultParams: false,
                requestType: DataRequestType.findOne,
                onSuccess: any(named: 'onSuccess'),
              ),
            );
          });

          test('does not add default query if custom query is set', () async {
            final filter = Filter.value<int>().build();
            sut.defaultQueryFilter = Filter.key().build();

            await sut.sendRequest<TestDataModel>(
              testUriWithId & filter,
              requestType: DataRequestType.findOne,
              onSuccess: mockOnSuccess,
            );

            verify(
              () => mockRemoteAdapter.sendRequest<TestDataModel>(
                testUriWithId & filter,
                method: DataRequestMethod.GET,
                omitDefaultParams: false,
                requestType: DataRequestType.findOne,
                onSuccess: any(named: 'onSuccess'),
              ),
            );
          });
        });

        group('save', () {
          test(
            'with POST uses transformCreated to transform received data',
            () async {
              when(() => mockOnSuccess.call(any())).thenReturn(testResult);

              final result = await sut.sendRequest<TestDataModel>(
                testUri,
                method: DataRequestMethod.POST,
                headers: testHeaders,
                omitDefaultParams: true,
                requestType: DataRequestType.save,
                key: testKey,
                body: '{"data": 10}',
                onSuccess: mockOnSuccess,
                onError: mockOnError,
              );

              expect(result, testResult);
              final onSuccess = verify(
                () => mockRemoteAdapter.sendRequest<TestDataModel>(
                  testUri,
                  method: DataRequestMethod.POST,
                  headers: testHeaders,
                  omitDefaultParams: true,
                  requestType: DataRequestType.save,
                  key: testKey,
                  body: '{"data": 10}',
                  onSuccess: captureAny(named: 'onSuccess'),
                  onError: mockOnError,
                ),
              ).captured.cast<OnData<TestDataModel>>().single;

              final onSuccessResult = onSuccess({'name': testId});
              expect(onSuccessResult, testResult);

              verify(
                () => mockOnSuccess.call({'id': testId, 'data': 10}),
              );
            },
            onPlatform: <String, dynamic>{
              'js': const Skip('Cannot test internal methods in JS')
            },
          );

          group('with PUT', () {
            final testUriWithId = testUri / testId;

            test(
              'uses transformOne to transform received data',
              () async {
                when(() => mockOnSuccess.call(any())).thenReturn(testResult);

                final result = await sut.sendRequest<TestDataModel>(
                  testUriWithId,
                  method: DataRequestMethod.PUT,
                  headers: testHeaders,
                  omitDefaultParams: true,
                  requestType: DataRequestType.save,
                  key: testKey,
                  body: testBody,
                  onSuccess: mockOnSuccess,
                  onError: mockOnError,
                );

                expect(result, testResult);
                final onSuccess = verify(
                  () => mockRemoteAdapter.sendRequest<TestDataModel>(
                    testUriWithId,
                    method: DataRequestMethod.PUT,
                    headers: testHeaders,
                    omitDefaultParams: true,
                    requestType: DataRequestType.save,
                    key: testKey,
                    body: testBody,
                    onSuccess: captureAny(named: 'onSuccess'),
                    onError: mockOnError,
                  ),
                ).captured.cast<OnData<TestDataModel>>().single;

                final onSuccessResult = onSuccess({'data': 1});
                expect(onSuccessResult, testResult);

                verify(
                  () => mockOnSuccess.call({'id': testId, 'data': 1}),
                );
              },
              onPlatform: <String, dynamic>{
                'js': const Skip('Cannot test internal methods in JS')
              },
            );

            test('removes id from body before sending the request', () async {
              await sut.sendRequest<TestDataModel>(
                testUriWithId,
                method: DataRequestMethod.PUT,
                requestType: DataRequestType.save,
                body: '{"id": "$testId", "data": 10}',
                onSuccess: mockOnSuccess,
              );

              verify(
                () => mockRemoteAdapter.sendRequest<TestDataModel>(
                  testUriWithId,
                  method: DataRequestMethod.PUT,
                  omitDefaultParams: false,
                  requestType: DataRequestType.save,
                  body: '{"data":10}',
                  onSuccess: any(named: 'onSuccess'),
                ),
              );
            });
          });
        });

        testData<DataRequestType>(
          'simply forwards arguments for other request types',
          const [
            DataRequestType.delete,
            DataRequestType.adhoc,
          ],
          (fixture) async {
            final result = await sut.sendRequest<TestDataModel>(
              testUri,
              method: DataRequestMethod.OPTIONS,
              headers: testHeaders,
              omitDefaultParams: true,
              requestType: fixture,
              key: testKey,
              body: testBody,
              onSuccess: mockOnSuccess,
              onError: mockOnError,
            );

            expect(result, testResult);
            verify(
              () => mockRemoteAdapter.sendRequest<TestDataModel>(
                testUri,
                method: DataRequestMethod.OPTIONS,
                headers: testHeaders,
                omitDefaultParams: true,
                requestType: fixture,
                key: testKey,
                body: testBody,
                onSuccess: mockOnSuccess,
                onError: mockOnError,
              ),
            );
          },
        );
      });
    });

    group('internals', () {
      test('generateGetUri generates full uri for get requests', () async {
        final testUri1 = Uri.http('localhost', '/test');
        const uriSubPath = 'data';
        const testDefaultParams = {'a': 1, 'b': true};

        when(() => mockRemoteAdapter.baseUrl).thenReturn(testUri1.toString());
        when(() => mockRemoteAdapter.urlForFindOne(any<dynamic>(), any()))
            .thenReturn(uriSubPath);
        when(() => mockRemoteAdapter.defaultParams)
            .thenReturn(testDefaultParams);

        const testId = 'test-id';
        const testParams = {'c': 4.2};
        final uri = await sut.generateGetUri(testId, testParams);

        expect(
          uri,
          Uri.parse(
            'http://localhost/test/data.json?a=1&b=true&auth=id-token&c=4.2',
          ),
        );

        verifyInOrder([
          () => mockRemoteAdapter.defaultParams,
          () => mockRemoteAdapter.baseUrl,
          () => mockRemoteAdapter.urlForFindOne(
                testId,
                <String, dynamic>{
                  ...testDefaultParams,
                  'auth': testIdToken,
                  ...testParams,
                },
              ),
        ]);
      });

      test('generateHeaders generates full headers for get requests', () async {
        const testDefaultHeaders = {'a': '1', 'b': 'true'};

        when(() => mockRemoteAdapter.defaultHeaders)
            .thenReturn(testDefaultHeaders);

        const testHeaders = {'c': 'x'};
        final headers = await sut.generateHeaders(testHeaders);

        expect(headers, {...testDefaultHeaders, ...testHeaders});

        verify(() => mockRemoteAdapter.defaultHeaders);
      });
    });
  });
}
