import 'package:flutter/material.dart';
import '/models/connection.dart' as model;
import '/widgets/file.dart' as widget;
import '/models/file.dart' as model;

class Connection extends StatelessWidget {
  final model.Connection connection;
  final void Function(model.File file)? onDownload;

  const Connection({super.key, required this.connection, this.onDownload});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      children: [
        for (model.File file in connection.files)
          widget.File(file: file, onDownload: onDownload),
      ],
    );
  }
}
