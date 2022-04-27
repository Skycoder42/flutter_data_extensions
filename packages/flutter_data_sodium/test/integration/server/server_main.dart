import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

import 'client_messages.dart';
import 'server_messages.dart';

Future<void> hybridMain(StreamChannel channel, Object? message) =>
    TestWebServer(channel).run();

class TestWebServer {
  final StreamChannel channel;
  late final HttpServer _server;
  late final StreamSubscription<ClientMessage> _channelSub;
  late final StreamSubscription<HttpRequest> _serverSub;

  final _handlerQueue = Queue<HttpHandlerMessage>();

  TestWebServer(this.channel);

  Future<void> run() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _channelSub = ClientMessage.fromChannel(channel).listen(
      _handleClientMessage,
      onDone: () => _server.close(),
      cancelOnError: true,
    );
    _serverSub = _server.listen(
      _handleServerRequest,
      onDone: _dispose,
      cancelOnError: true,
    );

    _send(PortMessage(_server.port));
  }

  void _send(ServerMessage message) => channel.sink.add(message.toJson());

  Future<void> _dispose() async {
    await _channelSub.cancel();
    await _serverSub.cancel();

    if (_handlerQueue.isNotEmpty) {
      channel.sink.addError(
        StateError('Server has ${_handlerQueue.length} unprocessed handlers'),
        StackTrace.current,
      );
    }

    await channel.sink.close();
  }

  Future<void> _handleServerRequest(HttpRequest request) async {
    request.response.headers.add('Access-Control-Allow-Origin', '*');

    if (_handlerQueue.isEmpty) {
      request.response.statusCode = 500;
      request.response.writeln('No handler prepared');
      await request.response.close();
      return;
    }

    final handler = _handlerQueue.removeFirst();
    if (!await _validateRequestFor(
      request,
      request.uri,
      handler.requestUri,
      'Invalid request URI',
    )) {
      return;
    }

    if (!await _validateRequestFor(
      request,
      request.headers,
      handler.requestHeaders,
      'Invalid request headers',
      _compareHeaders,
    )) {
      return;
    }

    final bodyString =
        await request.cast<List<int>>().transform(utf8.decoder).join();
    if (!await _validateRequestFor<Object?, Object?>(
      request,
      bodyString.isNotEmpty ? json.decode(bodyString) : null,
      handler.requestBody,
      'Invalid request body',
    )) {
      return;
    }

    request.response.statusCode = handler.responseStatusCode;
    for (final header in handler.responseHeaders.entries) {
      request.response.headers.add(header.key, header.value);
    }
    if (handler.responseBody != null) {
      request.response.write(json.encode(handler.requestBody));
    }
    await request.response.close();
  }

  void _handleClientMessage(ClientMessage clientMessage) {
    if (clientMessage is HttpHandlerMessage) {
      _handlerQueue.add(clientMessage);
      _send(HttpHandlerAckMessage(clientMessage.id));
    } else if (clientMessage is ExitMessage) {
      _server.close();
    } else {
      throw UnsupportedError(
        'Cannot handle client message of type ${clientMessage.runtimeType}',
      );
    }
  }

  Future<bool> _validateRequestFor<TActual, TExpected>(
    HttpRequest request,
    TActual actual,
    TExpected expected, [
    String? reason,
    bool Function(TActual actual, TExpected expected)? compare,
  ]) async {
    if (!(compare?.call(actual, expected) ?? actual == expected)) {
      final message = '${reason ?? 'Invalid request'}. '
          'Expected "$expected", but was "$actual"';
      // ignore: avoid_print
      print('ERROR: $message');
      request.response.statusCode = 400;
      request.response.writeln(message);
      await request.response.close();
      return false;
    }

    return true;
  }

  bool _compareHeaders(HttpHeaders actual, Map<String, dynamic> expected) {
    for (final entry in expected.entries) {
      if (actual.value(entry.key) != entry.value) {
        return false;
      }
    }

    return true;
  }
}
