import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import '/models/file.dart' as model;
import '/utils/util.dart';

class File extends StatelessWidget {
  final model.File file;
  const File({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(file.name),
        subtitle: Text(getReadableSize(file.size)),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            web.window
                .open('http://localhost:8080/download/${file.id}', '_blank');
          },
        ),
      ),
    );
  }
}
