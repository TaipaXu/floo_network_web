import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class MyFile {
  final String id = const Uuid().v4();
  final String name;
  final int size;
  Uint8List bytes;

  MyFile({
    required this.name,
    required this.size,
    required this.bytes,
  });
}
