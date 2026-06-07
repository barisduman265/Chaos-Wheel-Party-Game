import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<XFile> createShareImageFile(Uint8List bytes, String fileName) async {
  return XFile.fromData(bytes, mimeType: 'image/png', name: fileName);
}

/// No-op on platforms without a filesystem (web): the share data lives in
/// memory, so there is no temp file to clean up.
Future<void> cleanupShareImageFile(XFile file) async {}
