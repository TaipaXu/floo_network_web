import 'package:flutter/material.dart';
import '/models/connection.dart' as model;
import '/widgets/file.dart' as widget;
import '/models/file.dart' as model;

class Connection extends StatefulWidget {
  final model.Connection connection;
  final void Function(model.File file)? onDownload;

  const Connection({super.key, required this.connection, this.onDownload});

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          for (model.File file in this.widget.connection.files)
            widget.File(file: file, onDownload: this.widget.onDownload),
        ],
      ),
    );
  }
}
