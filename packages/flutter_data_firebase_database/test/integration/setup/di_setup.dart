import 'package:flutter_data/flutter_data.dart';
import 'package:meta/meta.dart';
import 'package:universal_io/io.dart';

import '../repositories/test.data.dart';
import 'setup.dart';

mixin DiSetup on Setup {
  late final Directory _testDir;

  late final ProviderContainer di;

  @override
  @mustCallSuper
  Future<void> setUpAll() async {
    await super.setUpAll();

    _testDir = await Directory.systemTemp.createTemp();
    di = ProviderContainer(
      overrides: [
        configureRepositoryLocalStorage(
          baseDirFn: () => _testDir.path,
        ),
      ],
    );
  }

  @override
  @mustCallSuper
  Future<void> tearDownAll() async {
    try {
      di.dispose();
      await di.pump();

      await _testDir.delete(recursive: true);
    } finally {
      await super.tearDownAll();
    }
  }
}
