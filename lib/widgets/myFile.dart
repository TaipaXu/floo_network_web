import 'package:flutter/material.dart';
import '/models/myFile.dart' as model;
import '/utils/util.dart';

class File extends StatelessWidget {
  final model.MyFile file;
  final void Function(model.MyFile file)? onRemove;
  const File({super.key, required this.file, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text(file.name),
        subtitle: Text(getReadableSize(file.size)),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            onRemove?.call(file);
          },
        ),
      ),
    );
  }
}
