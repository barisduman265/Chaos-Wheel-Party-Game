import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<XFile> createShareImageFile(Uint8List bytes, String fileName) async {
  final directory = await getTemporaryDirectory();
  // Remove any leftover share images from previous sessions before writing a
  // new one, so report screenshots don't accumulate in temp storage.
  await _removeStaleShareImages(directory, keep: fileName);
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return XFile(file.path, mimeType: 'image/png', name: fileName);
}

/// Deletes a temporary share image once the platform share sheet is done with
/// it. Safe to call with any path; failures are ignored.
Future<void> cleanupShareImageFile(XFile file) async {
  try {
    final temp = File(file.path);
    if (await temp.exists()) {
      await temp.delete();
    }
  } catch (_) {
    // Best-effort cleanup; the OS temp cleaner will handle leftovers.
  }
}

Future<void> _removeStaleShareImages(
  Directory directory, {
  required String keep,
}) async {
  try {
    final entries = directory.listSync();
    for (final entry in entries) {
      if (entry is! File) continue;
      final name = entry.uri.pathSegments.last;
      if (name == keep) continue;
      if (name.startsWith('chaos_report_') && name.endsWith('.png')) {
        try {
          entry.deleteSync();
        } catch (_) {
          // Ignore files we cannot delete.
        }
      }
    }
  } catch (_) {
    // Listing can fail on some platforms; cleanup is best-effort.
  }
}
