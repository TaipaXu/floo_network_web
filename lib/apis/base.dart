import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '/models/file.dart' as model;
import '/models/myFile.dart' as model;

typedef OnMessage = void Function(String message);

class Api {
  final String ip;
  final int port;
  WebSocketChannel? channel;
  final OnMessage? onMessage;
  final VoidCallback? onDisconnected;

  Api(
      {required this.ip,
      required this.port,
      this.onMessage,
      this.onDisconnected});

  void start() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://$ip:$port'),
    );

    channel!.stream.listen((dynamic message) {
      print('Received: $message');
      onMessage?.call(message as String);
    }, onDone: () {
      print('Disconnected');
      onDisconnected?.call();
    }, onError: (error) {
      print('Error: $error');
    });
  }

  void requestDownloadFile(model.File file) {
    final String message = jsonEncode({
      'type': 'downloadFile',
      'id': file.id,
    });
    _send(message);
  }

  void sendMyFilesInfoToServer(List<model.MyFile> myFiles) {
    final List<Map<String, dynamic>> files = [];
    for (final myFile in myFiles) {
      files.add({
        'id': myFile.id,
        'name': myFile.name,
        'size': myFile.size,
      });
    }
    final String message = jsonEncode({
      'type': 'files',
      'files': files,
    });
    _send(message);
  }

  void _send(String message) {
    channel?.sink.add(message);
  }
}
