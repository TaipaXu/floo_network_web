import 'package:flutter/material.dart';
import '/models/file.dart' as model;
import '/utils/util.dart';

class File extends StatelessWidget {
  final model.File file;
  final void Function(model.File file)? onDownload;
  const File({super.key, required this.file, this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text(file.name),
        subtitle: Text(getReadableSize(file.size)),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            onDownload?.call(file);
          },
        ),
      ),
    );
  }
}
