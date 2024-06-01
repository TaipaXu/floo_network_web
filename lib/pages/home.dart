import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:file_picker/file_picker.dart';
import '/models/connection.dart' as model;
import '/pages/connection.dart' as page;
import '/pages/myFiles.dart' as page;
import '/models/file.dart' as model;
import '/models/myFile.dart' as model;
import '/apis/base.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _ip;
  int? _port;
  final List<model.MyFile> _myFiles = [];
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

  void _addMyFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      List<PlatformFile> files = result.files;
      final List<model.MyFile> myFiles = [];
      for (final file in files) {
        myFiles.add(model.MyFile(
          name: file.name,
          size: file.size,
          fileBytes: file.bytes!,
        ));
      }
      setState(() {
        _myFiles.addAll(myFiles);
      });
      _api?.sendMyFilesInfoToServer(_myFiles);
    }
  }

  void _removeMyFile(model.MyFile file) {
    setState(() {
      _myFiles.remove(file);
    });
    _api?.sendMyFilesInfoToServer(_myFiles);
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
          final String myIp = data['you'];
          List<model.Connection> connections = [];
          for (final key in data['files'].keys) {
            if (myIp == key) {
              continue;
            }
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
        } else if (type == 'prepareUpload') {
          final String fileId = data['id'];
          String ip = data['ip'];
          if (ip == 'server') {
            ip = _ip!;
          }
          final int port = data['port'];
          final model.MyFile? myFile = _myFiles.firstWhere(
            (element) => element.id == fileId,
          );
          print('myFile ${myFile?.id}');
          if (myFile != null) {
            _api?.uploadFile(url: 'http://$ip:$port/', myFile: myFile);
          }
        }
      },
      onDisconnected: () {
        print('Disconnected');
        setState(() {
          _connections.clear();
        });
      },
    );
    _api?.start();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _connections.length + 1,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: const Text('Floo Network'),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_open),
              onPressed: _addMyFiles,
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              const Tab(
                text: 'My Files',
              ),
              for (final connection in _connections)
                Tab(
                  text: connection.ip,
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            page.MyFiles(
              myFiles: _myFiles,
              onRemove: _removeMyFile,
            ),
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
