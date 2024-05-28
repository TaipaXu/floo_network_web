import '/models/file.dart' as model;

class Connection {
  final String ip;
  List<model.File> files = [];

  Connection({
    required this.ip,
    List<model.File> files = const [],
  }) : files = List<model.File>.from(files);
}
