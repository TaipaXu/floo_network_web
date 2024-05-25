String getReadableSize(int size) {
  if (size < 1024) {
    return "$size B";
  } else if (size < 1024 * 1024) {
    return "${(size / 1024).toStringAsFixed(1)} KB";
  } else if (size < 1024 * 1024 * 1024) {
    return "${(size / 1024 / 1024).toStringAsFixed(1)} MB";
  } else {
    return "${(size / 1024 / 1024 / 1024).toStringAsFixed(1)} GB";
  }
}
