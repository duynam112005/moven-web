// Stub file for non-web platforms.
// When running on Dart VM (tests, desktop), this file is used instead of dart:html.
// All methods are no-ops or throw unsupported errors.

/// Stub for html.FileUploadInputElement
class FileUploadInputElement {
  String accept = '';
  bool multiple = false;
  List<_StubFile>? files;

  void click() {}

  Stream<dynamic> get onChange => const Stream.empty();
}

/// Stub for html.File
class _StubFile {
  final String name = '';
}

/// Stub for html.FileReader
class FileReader {
  dynamic result;

  void readAsArrayBuffer(dynamic file) {}

  Stream<dynamic> get onLoad => const Stream.empty();
}
