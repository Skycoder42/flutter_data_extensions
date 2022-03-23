import 'package:dart_test_tools/test.dart';
import 'package:flutter_data_firebase_database/src/queries/format_mode.dart';
import 'package:flutter_data_firebase_database/src/queries/request_config.dart';
import 'package:flutter_data_firebase_database/src/queries/timeout.dart';
import 'package:flutter_data_firebase_database/src/queries/write_size_limit.dart';
import 'package:test/test.dart' hide Timeout;
import 'package:tuple/tuple.dart';

void main() {
  group('RequestConfig', () {
    testData<Tuple2<RequestConfig, Map<String, String>>>(
      'generates correct params from config',
      const [
        Tuple2(RequestConfig(), {}),
        Tuple2(RequestConfig(shallow: false), {'shallow': 'false'}),
        Tuple2(RequestConfig(format: FormatMode.export), {'format': 'export'}),
        Tuple2(RequestConfig(timeout: Timeout.s(5)), {'timeout': '5s'}),
        Tuple2(
          RequestConfig(writeSizeLimit: WriteSizeLimit.medium),
          {'writeSizeLimit': 'medium'},
        ),
        Tuple2(
          RequestConfig(
            shallow: true,
            format: FormatMode.export,
            timeout: Timeout.min(10),
            writeSizeLimit: WriteSizeLimit.unlimited,
          ),
          {
            'shallow': 'true',
            'format': 'export',
            'timeout': '10min',
            'writeSizeLimit': 'unlimited',
          },
        ),
      ],
      (fixture) {
        expect(fixture.item1.asParams, fixture.item2);
      },
    );
  });
}
