import 'dart:typed_data';

class ScanImageFile {
  const ScanImageFile({
    required this.bytes,
    required this.filename,
    this.path = '',
    this.mimeType,
  });

  final Uint8List bytes;
  final String filename;
  final String path;
  final String? mimeType;
}
