// ignore_for_file: prefer_const_constructors
import 'package:dart_test_tools/test.dart';
import 'package:flutter_data_firebase_database/src/queries/timeout.dart';
import 'package:test/test.dart' hide Timeout;
import 'package:tuple/tuple.dart';

void main() {
  group('Timeout', () {
    testData<Tuple3<Timeout, Duration, String>>(
        'constructs correct timeouts from unit constructors', const [
      Tuple3(Timeout.ms(10), Duration(milliseconds: 10), '10ms'),
      Tuple3(Timeout.ms(20000), Duration(seconds: 20), '20000ms'),
      Tuple3(Timeout.s(10), Duration(seconds: 10), '10s'),
      Tuple3(Timeout.s(180), Duration(minutes: 3), '180s'),
      Tuple3(Timeout.min(10), Duration(minutes: 10), '10min'),
    ], (fixture) {
      expect(fixture.item1.duration, fixture.item2);
      expect(fixture.item1.toString(), fixture.item3);
    });

    testData<Tuple2<Duration, Timeout>>(
        'fromDuration converts to correct timeout', const [
      Tuple2(Duration(milliseconds: 60), Timeout.ms(60)),
      Tuple2(Duration(milliseconds: 6000), Timeout.s(6)),
      Tuple2(Duration(milliseconds: 6500), Timeout.ms(6500)),
      Tuple2(Duration(milliseconds: 60000), Timeout.min(1)),
      Tuple2(Duration(milliseconds: 63000), Timeout.s(63)),
      Tuple2(Duration(milliseconds: 63500), Timeout.ms(63500)),
    ], (fixture) {
      final t = Timeout.fromDuration(fixture.item1);
      expect(t, fixture.item2);
      expect(t.duration, fixture.item1);
    });

    test(
      'Limits Timeouts to positive times up to 15 minutes',
      () {
        expect(() => Timeout.ms(-5), throwsA(isA<AssertionError>()));
        expect(
          () => Timeout.ms(15 * 60 * 1000 + 1),
          throwsA(isA<AssertionError>()),
        );
        expect(() => Timeout.s(-5), throwsA(isA<AssertionError>()));
        expect(() => Timeout.s(15 * 60 + 1), throwsA(isA<AssertionError>()));
        expect(() => Timeout.min(-5), throwsA(isA<AssertionError>()));
        expect(() => Timeout.min(15 + 1), throwsA(isA<AssertionError>()));
        expect(
          () => Timeout.fromDuration(const Duration(microseconds: 10)),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => Timeout.fromDuration(const Duration(minutes: 20)),
          throwsA(isA<AssertionError>()),
        );
      },
      onPlatform: <String, dynamic>{
        'browser': [
          Skip('Freezed asserts do not work in the browser yet'),
        ]
      },
    );
  });
}
