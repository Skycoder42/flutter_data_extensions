import 'package:stream_channel/stream_channel.dart';

abstract class ServerMessage {
  static const typeKey = 'type';

  static Stream<ServerMessage> fromChannel(StreamChannel streamChannel) =>
      streamChannel.stream
          .cast<Map>()
          .map((m) => Map<String, dynamic>.unmodifiable(m))
          .map(ServerMessage.fromJson);

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    switch (json[typeKey]) {
      case PortMessage.type:
        return PortMessage.fromJson(json);
      case HttpHandlerAckMessage.type:
        return HttpHandlerAckMessage.fromJson(json);
      default:
        throw ArgumentError.value(
          json,
          'json',
          'Invalid json type: ${json[typeKey]}',
        );
    }
  }

  Map<String, dynamic> toJson();
}

class PortMessage implements ServerMessage {
  static const type = 'port';

  final int port;

  const PortMessage(this.port);

  PortMessage.fromJson(Map<String, dynamic> json) : port = json['port'] as int;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ServerMessage.typeKey: type,
        'port': port,
      };
}

class HttpHandlerAckMessage implements ServerMessage {
  static const type = 'http-handler-ack';

  final int id;

  const HttpHandlerAckMessage(this.id);

  HttpHandlerAckMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ServerMessage.typeKey: type,
        'id': id,
      };
}
