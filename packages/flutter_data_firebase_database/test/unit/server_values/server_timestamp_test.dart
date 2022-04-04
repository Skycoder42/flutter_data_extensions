import 'package:flutter_data_firebase_database/src/server_values/server_timestamp.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBinaryReader extends Mock implements BinaryReader {}

class MockBinaryWriter extends Mock implements BinaryWriter {}

void main() {
  group('ServerTimestamp', () {
    group('new', () {
      test('toJson creates server value', () {
        const st = ServerTimestamp();
        expect(st.toJson(), const {'.sv': 'timestamp'});
      });

      test('fromJson throws exception for server value', () {
        expect(
          () => ServerTimestamp.fromJson(const {'.sv': 'timestamp'}),
          throwsArgumentError,
        );
      });

      test('dateTime throw unsupported error', () {
        const st = ServerTimestamp();
        expect(() => st.dateTime, throwsUnsupportedError);
      });
    });

    group('value', () {
      test('toJson creates millis since epoch json value', () {
        final now = DateTime.now();
        final st = ServerTimestamp.value(now);

        expect(st.toJson(), now.millisecondsSinceEpoch);
      });

      test('fromJson converts millis to utc timestamp', () {
        final now = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
          isUtc: true,
        );
        final st = ServerTimestamp.fromJson(now.millisecondsSinceEpoch);
        st.maybeWhen(
          null,
          value: (value) => expect(value, now),
          orElse: () => fail('Unexpected server incrementable: $st'),
        );
      });

      test('dateTime returns internal date time value', () {
        final dt = DateTime.now();
        final st = ServerTimestamp.value(dt);
        expect(st.dateTime, dt);
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

        expect(data, const ServerTimestamp());
        verify(() => mockBinaryReader.readByte());
        verifyNoMoreInteractions(mockBinaryReader);
      });

      test('creates server timestamp value from data', () {
        final dtValue = DateTime.now();
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
        sut.write(mockBinaryWriter, const ServerTimestamp());

        verify(() => mockBinaryWriter.writeByte(1));
        verifyNoMoreInteractions(mockBinaryWriter);
      });

      test('writes server timestamp value', () {
        final dtValue = DateTime.now();
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
