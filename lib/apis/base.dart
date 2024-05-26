import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '/models/file.dart' as model;

typedef OnMessage = void Function(String message);

class Api {
  final String ip;
  final int port;
  WebSocketChannel? channel;
  final OnMessage? onMessage;

  Api({required this.ip, required this.port, this.onMessage});

  void start() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://$ip:$port'),
    );

    channel!.stream.listen((dynamic message) {
      print('Received: $message');
      onMessage?.call(message as String);
    });
  }

  void requestDownloadFile(model.File file) {
    final String message = jsonEncode({
      'type': 'downloadFile',
      'id': file.id,
    });
    _send(message);
  }

  void _send(String message) {
    channel?.sink.add(message);
  }
}
