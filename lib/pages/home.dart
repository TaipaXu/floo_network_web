import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:convert';
import '/models/connection.dart' as model;
import 'connection.dart' as page;
import '/models/file.dart' as model;
import '/apis/base.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _ip;
  int? _port;
  final List<model.Connection> _connections = [];
  Api? _api;

  Future<void> _showJoinDialog() async {
    String? ip;
    int? port;

    final (String inputIp, int inputPort) = await showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Join a channel'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'IP address',
                  ),
                  onChanged: (String value) {
                    ip = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Port',
                  ),
                  onChanged: (String value) {
                    port = int.tryParse(value);
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    if (ip != null && port != null) {
                      Navigator.pop(context, (ip, port));
                    }
                  },
                  child: const Text('Join'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    print('inputIp: $inputIp, inputPort: $inputPort');
    _ip = inputIp;
    _port = inputPort;

    _start();
  }

  void _start() {
    _api = Api(
      ip: _ip!,
      port: _port!,
      onMessage: (String message) {
        print('Received: $message');
        final data = jsonDecode(message);
        final String type = data['type'];
        print('type: $type');
        if (type == 'files') {
          List<model.Connection> connections = [];
          for (final key in data['files'].keys) {
            final List<model.File> files = [];
            for (final file in data['files'][key]) {
              files.add(model.File(
                id: file['id'],
                name: file['name'],
                size: file['size'],
              ));
            }
            connections.add(model.Connection(
              ip: key,
              port: _port!,
              files: files,
            ));
          }
          print('connections: $connections');
          setState(() {
            _connections.clear();
            _connections.addAll(connections);
          });
        } else if (type == 'uploadFileReady') {
          final String ip = data['ip'];
          final int port = data['port'];
          web.window.open('http://$ip:$port/', '_blank');
        }
      },
    );
    _api?.start();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _connections.length,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: const Text('title'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showJoinDialog();
              },
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              for (final connection in _connections)
                Tab(
                  text: connection.ip,
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            for (final connection in _connections)
              page.Connection(
                connection: connection,
                onDownload: (model.File file) {
                  print('onDownload: $file');
                  _api?.requestDownloadFile(file);
                },
              ),
          ],
        ),
      ),
    );
  }
}
