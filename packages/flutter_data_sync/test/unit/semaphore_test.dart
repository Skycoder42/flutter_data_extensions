import 'dart:async';

import 'package:flutter_data_sync/src/semaphore.dart';
import 'package:test/test.dart';

void main() {
  group('$Semaphore', () {
    late Semaphore sut;

    setUp(() {
      sut = Semaphore();
    });

    test('acquire at most max count resources works instantly', () {
      for (var i = 0; i < Semaphore.defaultMaxCount; ++i) {
        expect(
          sut.acquire().timeout(const Duration(milliseconds: 1)),
          completes,
        );
      }
    });

    test('acquire max count + 1 never completes', () {
      for (var i = 0; i < Semaphore.defaultMaxCount; ++i) {
        expect(
          sut.acquire().timeout(const Duration(milliseconds: 1)),
          completes,
        );
      }

      expect(
        sut.acquire().timeout(const Duration(seconds: 1)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('acquire throws if semaphore has already been disposed', () async {
      await sut.dispose();
      expect(() => sut.acquire(), throwsStateError);
    });

    test('release throws if no more resources can be released', () {
      expect(() => sut.release(), throwsStateError);
    });

    test('releasing resources makes the available for further consumption',
        () async {
      for (var i = 0; i < Semaphore.defaultMaxCount; ++i) {
        await sut.acquire();
      }

      for (var i = 0; i < Semaphore.defaultMaxCount ~/ 2; ++i) {
        sut.release();
      }

      for (var i = 0; i < Semaphore.defaultMaxCount ~/ 2; ++i) {
        expect(
          sut.acquire().timeout(const Duration(milliseconds: 1)),
          completes,
        );
      }

      expect(
        sut.acquire().timeout(const Duration(seconds: 1)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('release a resource passes it to a pending consumer', () async {
      for (var i = 0; i < Semaphore.defaultMaxCount; ++i) {
        await sut.acquire();
      }

      expect(sut.acquire(), completes);

      sut.release();
    });

    test('dispose immediately completes if all resources are free', () async {
      await sut.acquire();
      sut.release();

      expect(
        sut.dispose().timeout(const Duration(milliseconds: 1)),
        completes,
      );
    });

    test('dispose does not finish if acquired resources are held', () async {
      await sut.acquire();
      await sut.acquire();

      expect(
        sut.dispose().timeout(const Duration(seconds: 1)),
        throwsA(isA<TimeoutException>()),
      );

      sut.release();
    });

    test('dispose waits until all acquired resources have been freed',
        () async {
      await sut.acquire();
      await sut.acquire();
      await sut.acquire();

      expect(sut.dispose(), completes);

      sut
        ..release()
        ..release()
        ..release();
    });

    test('dispose triggers errors on waiting consumers', () async {
      for (var i = 0; i < Semaphore.defaultMaxCount; ++i) {
        await sut.acquire();
      }

      expect(sut.acquire(), throwsA(isA<SemaphoreDisposed>()));
      expect(sut.dispose(), completes);

      for (var i = 0; i < Semaphore.defaultMaxCount; ++i) {
        sut.release();
      }
    });

    test('disposing an already disposed semaphore throws', () async {
      await sut.dispose();
      expect(() => sut.dispose(), throwsStateError);
    });
  });
}
