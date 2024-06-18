import 'package:flutter/material.dart';
import '/widgets/myFile.dart' as widget;
import '/models/myFile.dart' as model;

class MyFiles extends StatelessWidget {
  final List<model.MyFile> myFiles;
  final void Function(model.MyFile file)? onRemove;

  const MyFiles({super.key, required this.myFiles, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
        children: [
          for (model.MyFile file in myFiles)
            widget.File(file: file, onRemove: onRemove),
        ],
      ),
    );
  }
}
