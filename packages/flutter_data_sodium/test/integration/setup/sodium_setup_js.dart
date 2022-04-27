@JS()
library sodium_setup_js;

import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart' show Sodium;
import 'package:sodium/sodium.js.dart';

import '../binaries/web/sodium.js.dart';

@JS()
@anonymous
class SodiumBrowserInit {
  external void Function(LibSodiumJS sodium) get onload;

  external factory SodiumBrowserInit({
    void Function(LibSodiumJS sodium) onload,
  });
}

mixin SodiumSetup {
  @protected
  Future<Sodium> loadSodium() async {
    final completer = Completer<LibSodiumJS>();

    setProperty(
      window,
      'sodium',
      SodiumBrowserInit(
        onload: allowInterop(completer.complete),
      ),
    );

    final script = ScriptElement()..text = sodiumJsSrc;
    document.head!.append(script);

    return SodiumInit.init(await completer.future);
  }
}
