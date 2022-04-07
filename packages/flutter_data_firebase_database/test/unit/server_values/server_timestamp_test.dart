import 'package:flutter_data_firebase_database/src/server_values/server_timestamp.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBinaryReader extends Mock implements BinaryReader {}

class MockBinaryWriter extends Mock implements BinaryWriter {}

void main() {
  group('ServerTimestamp', () {
    group('server', () {
      test('toJson creates server value', () {
        const st = ServerTimestamp.server();
        expect(st.toJson(), const {'.sv': 'timestamp'});
      });

      test('dateTime throw unsupported error', () {
        const st = ServerTimestamp.server();
        expect(() => st.dateTime, throwsUnsupportedError);
      });
    });

    group('value', () {
      test('throws assertion error if a non UTC timestamp is used as value',
          () {
        expect(
          () => ServerTimestamp.value(DateTime.now()),
          throwsA(isA<AssertionError>()),
        );
      });

      test('toJson creates millis since epoch json value', () {
        final now = DateTime.now().toUtc();
        final st = ServerTimestamp.value(now);

        expect(st.toJson(), now.millisecondsSinceEpoch);
      });

      test('dateTime returns internal date time value', () {
        final dt = DateTime.now().toUtc();
        final st = ServerTimestamp.value(dt);
        expect(st.dateTime, dt);
      });
    });

    group('fromJson', () {
      test('fromJson returns server value for server value placeholder json',
          () {
        expect(
          ServerTimestamp.fromJson(const {'.sv': 'timestamp'}),
          const ServerTimestamp.server(),
        );
      });

      test('fromJson converts millis to utc timestamp', () {
        final now = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
          isUtc: true,
        );
        expect(
          ServerTimestamp.fromJson(now.millisecondsSinceEpoch),
          ServerTimestamp.value(now),
        );
      });

      test('fromJson throws exception for invalid json', () {
        expect(
          () => ServerTimestamp.fromJson('invalid'),
          throwsArgumentError,
        );
      });
    });
  });

  group('ServerTimestampHiveAdapter', () {
    const customTypeId = 12;

    late ServerTimestampHiveAdapter sut;

    setUp(() {
      sut = const ServerTimestampHiveAdapter(customTypeId);
    });

    group('typeId', () {
      test('default adapter uses default type id of 71', () {
        const defaultSut = ServerTimestampHiveAdapter();
        expect(defaultSut.typeId, 71);
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

      test('creates server timestamp from data', () {
        when(() => mockBinaryReader.readByte()).thenReturn(1);

        final data = sut.read(mockBinaryReader);

        expect(data, const ServerTimestamp.server());
        verify(() => mockBinaryReader.readByte());
        verifyNoMoreInteractions(mockBinaryReader);
      });

      test('creates server timestamp value from data', () {
        final dtValue = DateTime.now().toUtc();
        when(() => mockBinaryReader.readByte()).thenReturn(2);
        when<dynamic>(() => mockBinaryReader.read()).thenReturn(dtValue);

        final data = sut.read(mockBinaryReader);

        expect(data, ServerTimestamp.value(dtValue));
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

      test('writes server timestamp', () {
        sut.write(mockBinaryWriter, const ServerTimestamp.server());

        verify(() => mockBinaryWriter.writeByte(1));
        verifyNoMoreInteractions(mockBinaryWriter);
      });

      test('writes server timestamp value', () {
        final dtValue = DateTime.now().toUtc();
        sut.write(mockBinaryWriter, ServerTimestamp.value(dtValue));

        verifyInOrder([
          () => mockBinaryWriter.writeByte(2),
          () => mockBinaryWriter.write(dtValue),
        ]);
        verifyNoMoreInteractions(mockBinaryWriter);
      });
    });
  });
}
