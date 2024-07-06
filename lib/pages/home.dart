import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:file_picker/file_picker.dart';
import 'package:x_responsive/x_responsive.dart';
import '/pages/connection.dart' as page;
import '/pages/myFiles.dart' as page;
import '/widgets/navbar.dart' as widget;
import '/models/connection.dart' as model;
import '/models/file.dart' as model;
import '/models/myFile.dart' as model;
import '/apis/base.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  String? _ip;
  int? _port;
  final List<model.MyFile> _myFiles = [];
  final List<model.Connection> _connections = [];
  Map<String, int> requestingFiles = {};
  Api? _api;

  @override
  void initState() {
    _getIpAndPortFromUrl();

    super.initState();
  }

  @override
  void dispose() {
    _api?.stop();

    super.dispose();
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
        final bool isExist = _myFiles.any((element) =>
            element.name == file.name &&
            element.size == file.size &&
            _areBytesEqual(element.bytes, file.bytes!));
        if (!isExist) {
          myFiles.add(model.MyFile(
            name: file.name,
            size: file.size,
            bytes: file.bytes!,
          ));
        }
      }
      if (myFiles.isNotEmpty) {
        setState(() {
          _myFiles.addAll(myFiles);
        });
        _api?.sendMyFilesInfoToServer(_myFiles);
      }
    }
  }

  bool _areBytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
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
          String fileId = data['fileId'];
          if (requestingFiles.containsKey(fileId)) {
            requestingFiles[fileId] = requestingFiles[fileId]! - 1;
            if (requestingFiles[fileId] == 0) {
              requestingFiles.remove(fileId);
            }

            String ip = data['ip'];
            if (ip == 'server') {
              ip = _ip!;
            }
            final int port = data['port'];
            web.window.open('http://$ip:$port/', '_blank');
          }
        } else if (type == 'prepareUpload') {
          final String fileId = data['fileId'];
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

  Widget get _connectionsWidgetLeft {
    return Container();
  }

  TabBar? get _connectionsWidgetTop {
    if (Condition.screenUp(Breakpoint.sm).check(context)) {
      return null;
    }
    return TabBar(
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      tabs: <Widget>[
        const Tab(
          text: 'My Files',
        ),
        for (final connection in _connections)
          Tab(
            text: connection.ip,
          ),
      ],
    );
  }

  Widget _sidebar(BuildContext context) {
    return Responsive.condition(
      condition: Condition.screenUp(Breakpoint.sm),
      child: Container(
        width: 80,
        height: double.infinity,
        color: const Color.fromARGB(31, 70, 70, 70),
        child: widget.Navbar(
          connections: _connections,
          activeIndex: DefaultTabController.of(context).index,
          onClick: (int index) {
            DefaultTabController.of(context).animateTo(index);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      animationDuration: Duration.zero,
      length: _connections.length + 1,
      child: Builder(
        builder: (BuildContext context) {
          DefaultTabController.of(context).addListener(() {
            setState(() {});
          });
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              title: const Text('Floo Network'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addMyFiles,
                ),
              ],
              bottom: _connectionsWidgetTop,
            ),
            body: Row(
              children: [
                _sidebar(context),
                Expanded(
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
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
                            if (requestingFiles.containsKey(file.id)) {
                              requestingFiles[file.id] =
                                  requestingFiles[file.id]! + 1;
                            } else {
                              requestingFiles[file.id] = 1;
                            }
                            _api?.requestDownloadFile(file);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
