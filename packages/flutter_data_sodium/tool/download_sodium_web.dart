import 'dart:io';

import 'package:http/http.dart' as http;

const _sodiumJsVersion = '0.7.10';

Future<void> main() async {
  final webTestDir = Directory('test/integration/binaries/web');
  await webTestDir.create(recursive: true);

  final baseUri = Uri.https(
    'raw.githubusercontent.com',
    '/jedisct1/libsodium.js/$_sodiumJsVersion/dist/browsers/sodium.js',
  );
  final data = await http.get(baseUri);
  final jsDartFileSink =
      File.fromUri(webTestDir.uri.resolve('sodium.js.dart')).openWrite()
        ..writeln("const sodiumJsSrc = r'''")
        ..write(data.body)
        ..writeln("''';");
  await jsDartFileSink.flush();
  await jsDartFileSink.close();
}
