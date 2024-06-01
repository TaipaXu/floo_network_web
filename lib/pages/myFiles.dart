import 'package:flutter/material.dart';
import '/widgets/myFile.dart' as widget;
import '/models/myFile.dart' as model;

class MyFiles extends StatefulWidget {
  final List<model.MyFile> myFiles;
  final void Function(model.MyFile file)? onRemove;

  const MyFiles({super.key, required this.myFiles, this.onRemove});

  @override
  State<MyFiles> createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> {
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
          for (model.MyFile file in this.widget.myFiles)
            widget.File(file: file, onRemove: this.widget.onRemove),
        ],
      ),
    );
  }
}
