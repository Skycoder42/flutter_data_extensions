import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_firebase_database/flutter_data_firebase_database.dart';

late final baseUrlProvider = StateProvider((ref) => '');

late final idTokenProvider = StateProvider<String?>((ref) => '');

mixin ExampleRemoteAdapter<T extends DataModel<T>>
    on FirebaseDatabaseAdapter<T> {
  // you can get the base url of your firebase application from the `databaseURL` value in the firebase config
  @override
  String get baseUrl => read(baseUrlProvider);

  @override
  String? get idToken => read(idTokenProvider);
}
