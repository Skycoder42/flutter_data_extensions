import '../repositories/test.data.dart';
import 'database_setup.dart';

mixin RepoSetup on DatabaseSetup {
  @override
  Future<void> setUpAll() async {
    await super.setUpAll();

    await di.read(repositoryInitializerProvider(verbose: true).future);
  }
}
