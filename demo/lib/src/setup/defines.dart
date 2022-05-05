import 'dart:convert';

import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:dotenv/src/parser.dart';
import 'package:flutter_data/flutter_data.dart';

late final definesInitProvider = FutureProvider(
  (ref) => Defines.loadFromBundle(),
);
late final definesProvider = Provider(
  (ref) => ref.watch(definesInitProvider).value!,
);

class Defines {
  final Map<String, String> _dotenvData;

  Defines(this._dotenvData);

  static Future<Defines> loadFromBundle([AssetBundle? assetBundle]) async =>
      (assetBundle ?? rootBundle).loadStructuredData(
        '.env',
        (value) async => Defines(
          const Parser().parse(
            const LineSplitter().convert(value),
          ),
        ),
      );

  String get apiKey => _dotenvData['FIREBASE_API_KEY']!;

  String get googleClientId => _dotenvData['GOOGLE_CLIENT_ID']!;

  String get googleClientSecret => _dotenvData['GOOGLE_CLIENT_SECRET']!;
}
