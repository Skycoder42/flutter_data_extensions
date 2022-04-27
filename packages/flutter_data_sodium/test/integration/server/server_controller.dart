import 'dart:async';

import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

import 'client_messages.dart';
import 'server_messages.dart';

class ServerController {
  late final StreamChannel _serverChannel;
  late final StreamSubscription<ServerMessage> _serverMessageSub;

  final _portCompleter = Completer<int>();
  final _ackCompleters = <int, Completer<void>>{};

  ServerController({
    bool autoTearDown = true,
    bool stayAlive = false,
  }) {
    _serverChannel = spawnHybridUri(
      '/test/integration/server/server_main.dart',
      stayAlive: stayAlive,
    );
    _serverMessageSub = ServerMessage.fromChannel(_serverChannel)
        .listen(_handleServerMessage, cancelOnError: true);

    if (autoTearDown) {
      addTearDown(dispose);
    }
  }

  Future<void> dispose() async {
    _send(const ExitMessage());
    await _serverMessageSub.asFuture<void>();
    await _serverChannel.sink.close();
  }

  Future<int> get port => _portCompleter.future;

  Future<Uri> get baseUrl =>
      port.then((port) => Uri.http('localhost:$port', ''));

  Future<void> prepareHandler(HttpHandlerMessage httpHandlerMessage) async {
    final completer = _ackCompleters.update(
      httpHandlerMessage.id,
      (_) => throw ArgumentError.value(
        httpHandlerMessage,
        'httpHandlerMessage',
        'Cannot prepare the same message twice',
      ),
      ifAbsent: () => Completer(),
    );

    _send(httpHandlerMessage);

    return completer.future;
  }

  void _send(ClientMessage message) =>
      _serverChannel.sink.add(message.toJson());

  void _handleServerMessage(ServerMessage serverMessage) {
    if (serverMessage is PortMessage) {
      if (!_portCompleter.isCompleted) {
        _portCompleter.complete(serverMessage.port);
      } else {
        throw StateError('Received second $PortMessage');
      }
    } else if (serverMessage is HttpHandlerAckMessage) {
      _ackCompleters.remove(serverMessage.id)?.complete();
    } else {
      throw UnsupportedError(
        'Cannot handle client message of type ${serverMessage.runtimeType}',
      );
    }
  }
}
