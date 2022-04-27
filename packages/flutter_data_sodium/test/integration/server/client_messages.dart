import 'dart:io';
import 'dart:math';

import 'package:stream_channel/stream_channel.dart';

abstract class ClientMessage {
  static const typeKey = 'type';

  static Stream<ClientMessage> fromChannel(StreamChannel streamChannel) =>
      streamChannel.stream
          .cast<Map<String, dynamic>>()
          .map(ClientMessage.fromJson);

  factory ClientMessage.fromJson(Map<String, dynamic> json) {
    switch (json[typeKey]) {
      case HttpHandlerMessage.type:
        return HttpHandlerMessage.fromJson(json);
      case ExitMessage.type:
        return ExitMessage.fromJson(json);
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

class HttpHandlerMessage implements ClientMessage {
  static const type = 'http-handler';

  final int id;
  final Uri requestUri;
  final Map<String, String> requestHeaders;
  final Object? requestBody;

  final int responseStatusCode;
  final Map<String, String> responseHeaders;
  final Object? responseBody;

  HttpHandlerMessage({
    required String requestPath,
    Map<String, dynamic>? requestQueryParameters,
    String? requestFragment,
    this.requestHeaders = const {},
    this.requestBody,
    this.responseStatusCode = HttpStatus.ok,
    this.responseHeaders = const {},
    this.responseBody,
  })  : id = Random.secure().nextInt(4294967295),
        requestUri = Uri.parse(requestPath).replace(
          queryParameters: requestQueryParameters,
          fragment: requestFragment,
        );

  HttpHandlerMessage.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        requestUri = Uri.parse(json['requestUri'] as String),
        requestHeaders = Map.unmodifiable(json['requestHeaders'] as Map),
        requestBody = json['requestBody'],
        responseStatusCode = json['responseStatusCode'] as int,
        responseHeaders = Map.unmodifiable(json['responseHeaders'] as Map),
        responseBody = json['responseBody'];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ClientMessage.typeKey: type,
        'id': id,
        'requestUri': requestUri.toString(),
        'requestHeaders': requestHeaders,
        'requestBody': requestBody,
        'responseStatusCode': responseStatusCode,
        'responseHeaders': responseHeaders,
        'responseBody': responseBody,
      };
}

class ExitMessage implements ClientMessage {
  static const type = 'exit';

  const ExitMessage();

  const ExitMessage.fromJson(Map<String, dynamic> _);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ClientMessage.typeKey: type,
      };
}
