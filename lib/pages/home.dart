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

  @override
  void initState() {
    _getIpAndPortFromUrl();

    super.initState();
  }

  void _getIpAndPortFromUrl() {
    final Uri uri = Uri.parse(web.window.location.href);
    final String ip = web.window.location.hostname;
    final String? port = uri.queryParameters['wsPort'];
    if (port != null) {
      setState(() {
        _ip = ip;
        _port = int.parse(port);
      });
      _start();
    }
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
          title: const Text('Floo Network'),
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
