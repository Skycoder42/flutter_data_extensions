import 'dart:async';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

abstract class Setup {
  @protected
  @mustCallSuper
  Future<void> setUpAll() => Future.value();

  @protected
  @mustCallSuper
  Future<void> tearDownAll() => Future.value();

  @protected
  @mustCallSuper
  Future<void> setUp() => Future.value();

  @protected
  @mustCallSuper
  Future<void> tearDown() => Future.value();

  void call() {
    test.setUpAll(setUpAll);
    test.tearDownAll(tearDownAll);

    test.setUp(setUp);
    test.tearDown(tearDown);
  }
}
