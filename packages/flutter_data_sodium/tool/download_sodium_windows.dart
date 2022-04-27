import 'dart:io';

import 'package:http/http.dart' as http;

const _sodiumVersion = '1.0.18';
const _vsVersion = 'v142';

Future<void> main() async {
  final baseUri = Uri.https(
    'download.libsodium.org',
    '/libsodium/releases/libsodium-$_sodiumVersion-stable-msvc.zip',
  );

  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    final data = await http.get(baseUri);
    final zipFile = File.fromUri(tmpDir.uri.resolve('libsodium.zip'));
    await zipFile.writeAsBytes(data.bodyBytes);
    final proc7z = await Process.start(
      '7z',
      ['x', '-y', '-o${tmpDir.path}', zipFile.path],
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await proc7z.exitCode;
    if (exitCode != 0) {
      throw Exception('7z failed with exit code $exitCode');
    }

    final libsodiumDll = File.fromUri(
      tmpDir.uri
          .resolve('libsodium/x64/Release/$_vsVersion/dynamic/libsodium.dll'),
    );
    if (!await libsodiumDll.exists()) {
      throw Exception('$libsodiumDll does not exist');
    }

    final winTestDir = Directory('test/integration/binaries/win');
    await winTestDir.create(recursive: true);
    await libsodiumDll.copy(
      winTestDir.uri.resolve('libsodium.dll').toFilePath(),
    );
  } finally {
    await tmpDir.delete(recursive: true);
  }
}
