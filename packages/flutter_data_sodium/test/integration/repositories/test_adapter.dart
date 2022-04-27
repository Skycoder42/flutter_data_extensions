import 'package:flutter_data/flutter_data.dart';
// ignore: test_library_import
import 'package:flutter_data_sodium/flutter_data_sodium.dart';
import 'package:sodium/sodium.dart';

mixin TestAdapter<T extends DataModel<T>> on SodiumRemoteAdapter<T> {
  static late final baseUrlProvider = Provider<Uri>(
    (ref) => throw UnimplementedError(),
  );

  static late final sodiumProvider = Provider<Sodium>(
    (ref) => throw UnimplementedError(),
  );

  static late final keyManagerProvider = Provider<KeyManager>(
    (ref) => throw UnimplementedError(),
  );

  @override
  String get baseUrl => read(baseUrlProvider).toString();

  @override
  Sodium get sodium => read(sodiumProvider);

  @override
  KeyManager get keyManager => read(keyManagerProvider);
}
