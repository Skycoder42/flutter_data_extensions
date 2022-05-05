import 'dart:typed_data';

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter_data_demo/src/setup/defines.dart';
import 'package:sodium_libs/sodium_libs.dart';

import '../../main.data.dart';

final localIdProvider = StateProvider((ref) => '');

final sodiumInitProvider = FutureProvider(
  (ref) => SodiumInit.init(),
);
final sodiumProvider = Provider(
  (ref) => ref.watch(sodiumInitProvider).value!,
);

final localEncryptionKeyProvider = Provider((ref) {
  ref.onDispose(() => ref.state.dispose());
  var sodium = ref.watch(sodiumProvider);
  return sodium.secureCopy(
    Uint8List.fromList(
      List.generate(
        sodium.crypto.secretBox.keyBytes,
        (index) => index,
      ),
    ),
  );
});

final initAllProvider = FutureProvider((ref) async {
  await ref.watch(definesInitProvider.future);
  await ref.watch(sodiumInitProvider.future);
  await ref.watch(repositoryInitializerProvider().future);
});
