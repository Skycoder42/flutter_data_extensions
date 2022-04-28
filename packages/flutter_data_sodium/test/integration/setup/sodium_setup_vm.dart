import 'dart:ffi';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

mixin SodiumSetup {
  @protected
  Future<Sodium> loadSodium({
    void Function(dynamic, Matcher) expect = expect,
    void Function(String) printOnFailure = printOnFailure,
  }) async {
    String libSodiumPath;
    if (Platform.isLinux) {
      final ldConfigRes = await Process.run('ldconfig', const ['-p']);
      printOnFailure('stderr: ${ldConfigRes.stderr}');
      expect(ldConfigRes.exitCode, equals(0));
      printOnFailure('stdout: ${ldConfigRes.stdout}');
      libSodiumPath = (ldConfigRes.stdout as String)
          .split('\n')
          .map((e) => e.split('=>').map((e) => e.trim()).toList())
          .where((e) => e.length == 2)
          .where((e) => e[0].contains('x86-64'))
          .map((e) => MapEntry(e[0].split(' ').first, e[1]))
          .where((e) => e.key.contains('libsodium.so'))
          .map((e) => e.value)
          .first;
    } else if (Platform.isWindows) {
      libSodiumPath = Directory.current.uri
          .resolve('test/integration/binaries/win/libsodium.dll')
          .toFilePath();
    } else if (Platform.isMacOS) {
      final libDir = Directory('/usr/local/Cellar/libsodium');
      final subDirs = await libDir
          .list()
          .where((e) => e is Directory)
          .cast<Directory>()
          .toList();
      expect(subDirs, isNotEmpty);
      subDirs.sort((lhs, rhs) => lhs.path.compareTo(rhs.path));
      libSodiumPath = '${subDirs.last.path}/lib/libsodium.dylib';
    } else {
      throw UnsupportedError(
        'Operating system ${Platform.operatingSystem} not supported',
      );
    }

    expect(await File(libSodiumPath).exists(), isTrue);
    // ignore: avoid_print
    print('Found libsodium at: $libSodiumPath');
    final dyLib = DynamicLibrary.open(libSodiumPath);
    return SodiumInit.init(dyLib);
  }
}
