import 'package:flutter_data_firebase_database/src/server_values/server_incrementable.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBinaryReader extends Mock implements BinaryReader {}

class MockBinaryWriter extends Mock implements BinaryWriter {}

void main() {
  _testIncrementable(testValue: 42);
  _testIncrementable(testValue: 4.2);

  group('ServerIncrementableHiveAdapter', () {
    const customTypeId = 21;

    late ServerIncrementableHiveAdapter<double> sut;

    setUp(() {
      sut = const ServerIncrementableHiveAdapter(customTypeId);
    });

    group('typeId', () {
      test('default adapter uses default type id of 71', () {
        const defaultSut = ServerIncrementableHiveAdapter<double>();
        expect(defaultSut.typeId, 72);
      });

      test('test adapter uses given type id', () {
        expect(sut.typeId, customTypeId);
      });
    });

    group('read', () {
      final mockBinaryReader = MockBinaryReader();

      setUp(() {
        reset(mockBinaryReader);
      });

      test('creates server incrementable from data', () {
        when(() => mockBinaryReader.readByte()).thenReturn(1);
        when<dynamic>(() => mockBinaryReader.read()).thenReturn(5.3);

        final data = sut.read(mockBinaryReader);

        expect(data, const ServerIncrementable.increment(5.3));
        verifyInOrder<dynamic>([
          () => mockBinaryReader.readByte(),
          () => mockBinaryReader.read(),
        ]);
        verifyNoMoreInteractions(mockBinaryReader);
      });

      test('creates server incrementable value from data', () {
        const icValue = 12.3;
        when(() => mockBinaryReader.readByte()).thenReturn(2);
        when<dynamic>(() => mockBinaryReader.read()).thenReturn(icValue);

        final data = sut.read(mockBinaryReader);

        expect(data, const ServerIncrementable.value(icValue));
        verifyInOrder<dynamic>([
          () => mockBinaryReader.readByte(),
          () => mockBinaryReader.read(),
        ]);
        verifyNoMoreInteractions(mockBinaryReader);
      });

      test('throws state error for unknown data', () {
        when(() => mockBinaryReader.readByte()).thenReturn(3);

        expect(() => sut.read(mockBinaryReader), throwsStateError);

        verify(() => mockBinaryReader.readByte());
        verifyNoMoreInteractions(mockBinaryReader);
      });
    });

    group('write', () {
      final mockBinaryWriter = MockBinaryWriter();

      setUp(() {
        reset(mockBinaryWriter);
      });

      test('writes server incrementable', () {
        const icValue = 11.1;
        sut.write(
          mockBinaryWriter,
          const ServerIncrementable.increment(icValue),
        );

        verifyInOrder([
          () => mockBinaryWriter.writeByte(1),
          () => mockBinaryWriter.write(icValue),
        ]);
        verifyNoMoreInteractions(mockBinaryWriter);
      });

      test('writes server incrementable value', () {
        const icValue = 12.35;
        sut.write(mockBinaryWriter, const ServerIncrementable.value(icValue));

        verifyInOrder([
          () => mockBinaryWriter.writeByte(2),
          () => mockBinaryWriter.write(icValue),
        ]);
        verifyNoMoreInteractions(mockBinaryWriter);
      });
    });
  });
}

void _testIncrementable<TValue extends num>({
  required TValue testValue,
}) =>
    group('${ServerIncrementable<TValue>}', () {
      group('increment', () {
        test('toJson creates incrementable server value', () {
          final si = ServerIncrementable<TValue>.increment(testValue);

          expect(si.toJson(), {
            '.sv': {'increment': testValue},
          });
        });

        test('value throws unsupported error', () {
          final si = ServerIncrementable<TValue>.increment(testValue);
          expect(() => si.value, throwsUnsupportedError);
        });
      });

      group('value', () {
        test('toJson creates simple value', () {
          final si = ServerIncrementable<TValue>.value(testValue);

          expect(si.toJson(), testValue);
        });

        test('value returns internal value', () {
          final si = ServerIncrementable<TValue>.value(testValue);
          expect(si.value, testValue);
        });
      });

      group('fromJson', () {
        test(
            'fromJson returns server incrementable '
            'for server incrementable placeholder', () {
          expect(
            ServerIncrementable<TValue>.fromJson({
              '.sv': {'increment': testValue}
            }),
            ServerIncrementable<TValue>.increment(testValue),
          );
        });

        test('fromJson can convert a simple value', () {
          expect(
            ServerIncrementable<TValue>.fromJson(testValue),
            ServerIncrementable<TValue>.value(testValue),
          );
        });

        test('fromJson throws for invalid json data', () {
          expect(
            () => ServerIncrementable<TValue>.fromJson('invalid'),
            throwsArgumentError,
          );
        });
      });
    });
