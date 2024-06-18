import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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

  void stop() {
    channel?.sink.close();
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

  void uploadFile({required String url, required model.MyFile myFile}) async {
    Map<String, dynamic> data = {
      'name': myFile.name,
      'file': base64Encode(myFile.bytes),
    };
    String body = json.encode(data);
    print('body $body');

    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    print('response ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Uploaded!');
    }
  }
}
