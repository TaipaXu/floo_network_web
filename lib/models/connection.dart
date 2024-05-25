import '/models/file.dart' as model;

class Connection {
  final String ip;
  final int port;
   List<model.File> files = [];

  Connection({
    required this.ip,
    required this.port,
    List<model.File> files = const [],
  }): files = List<model.File>.from(files);
}
