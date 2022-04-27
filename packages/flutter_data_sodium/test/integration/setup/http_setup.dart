import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_data/flutter_data.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

typedef HttpHandler = FutureOr<Response> Function(Request request);

Response jsonResponse(
  Object? jsonData, {
  int statusCode = HttpStatus.ok,
  Map<String, String> headers = const {},
}) =>
    Response(
      json.encode(jsonData),
      statusCode,
    );

extension JsonRequestX on Request {
  Object? get jsonBody => body.isNotEmpty ? json.decode(body) : null;
}

mixin HttpSetup {
  final _httpHandlers = Queue<HttpHandler>();

  void prepareHandler(HttpHandler handler) {
    _httpHandlers.add(handler);
  }

  Override createHttpOverride() {
    addTearDown(
      () => expect(_httpHandlers, isEmpty),
    );

    return httpClientProvider.overrideWithValue(
      MockClient(
        (request) async {
          expect(_httpHandlers, isNotEmpty);
          return _httpHandlers.removeFirst()(request);
        },
      ),
    );
  }
}
