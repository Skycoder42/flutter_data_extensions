import 'dart:async';
import 'package:test/test.dart' as test;

abstract class Setup {
  const Setup();

  FutureOr<void> setUpAll() {}
  FutureOr<void> tearDownAll() {}

  FutureOr<void> setUp() {}
  FutureOr<void> tearDown() {}

  static void setup(List<Setup> setups) {
    test.setUpAll(() async {
      for (final setup in setups) {
        await setup.setUpAll();
      }
    });

    test.tearDownAll(() async {
      for (final setup in setups.reversed) {
        await setup.tearDownAll();
      }
    });

    test.setUp(() async {
      for (final setup in setups) {
        await setup.setUp();
      }
    });

    test.tearDown(() async {
      for (final setup in setups.reversed) {
        await setup.tearDown();
      }
    });
  }
}
