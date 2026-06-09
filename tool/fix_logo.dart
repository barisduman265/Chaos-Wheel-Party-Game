// Zooms the existing app logo so the wheel fills the icon instead of floating
// in empty padding. It takes a square crop into the artwork (kept high enough
// to preserve the top pointer) and re-renders at 1024x1024 on a black canvas.
//
// Always reads the pristine backup so re-running is idempotent.
// Run from the project root:  dart run tool/fix_logo.dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final backup = File('tool/AppLogo_source.png');
  final input = backup.existsSync() ? backup : File('assets/AppLogo.png');
  final src = img.decodePng(input.readAsBytesSync());
  if (src == null) {
    stderr.writeln('Could not decode ${input.path}');
    exit(1);
  }

  // Square crop, as a fraction of the source width. Smaller = more zoom.
  const sideFrac = 0.78;
  // Where the top edge of the square sits (fraction of height). Kept small so
  // the aggressive top pointer is preserved while still trimming the border.
  const topFrac = 0.05;

  final side = (src.width * sideFrac).round();
  var sx = ((src.width - side) / 2).round();
  var sy = (src.height * topFrac).round();
  sx = sx.clamp(0, src.width - side);
  sy = sy.clamp(0, src.height - side);

  final cropped = img.copyCrop(src, x: sx, y: sy, width: side, height: side);
  final resized = img.copyResize(
    cropped,
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.cubic,
  );

  // Composite onto an opaque near-black canvas so any transparent corners are
  // dark rather than see-through.
  final canvas = img.Image(width: 1024, height: 1024)
    ..clear(img.ColorRgb8(6, 1, 12));
  img.compositeImage(canvas, resized);

  File('assets/AppLogo.png').writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('Cropped square $side at ($sx,$sy) -> assets/AppLogo.png');
}
