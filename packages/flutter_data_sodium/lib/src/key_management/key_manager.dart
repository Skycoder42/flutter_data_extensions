import 'package:sodium/sodium.dart';

abstract class KeyInfo {
  int get keyId;
  SecureKey get secureKey;
}

abstract class KeyManager {
  KeyInfo keyForType(String type);

  SecureKey keyForTypeAndId(String type, int keyId);
}
