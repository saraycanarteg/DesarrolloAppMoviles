import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final srcBytes = File('assets/icon/logoNavora.png').readAsBytesSync();
  final src = img.decodePng(srcBytes)!;

  // ---- App icon 512x512 (opaque white background, Play Store disallows alpha) ----
  final iconLogo = img.copyResize(src, width: 460, height: 460, interpolation: img.Interpolation.average);
  final icon = img.Image(width: 512, height: 512, numChannels: 3);
  img.fill(icon, color: img.ColorRgb8(255, 255, 255));
  final iconOffset = (512 - 460) ~/ 2;
  img.compositeImage(icon, iconLogo, dstX: iconOffset, dstY: iconOffset);
  File('legal/play_icon_512.png').writeAsBytesSync(img.encodePng(icon));

  // ---- Feature graphic 1024x500 ----
  final feature = img.Image(width: 1024, height: 500, numChannels: 3);
  // Gradient background matching the app theme (colorPrimario -> #0D2F63)
  const topColor = [17, 61, 122];
  const bottomColor = [13, 47, 99];
  const centerX = 512.0;
  const centerY = 250.0;
  const glowRadius = 300.0;
  const glowStrength = 0.30; // 0-1, cuánto se aclara el centro

  for (int y = 0; y < feature.height; y++) {
    final t = y / feature.height;
    final r = (topColor[0] + (bottomColor[0] - topColor[0]) * t).round();
    final g = (topColor[1] + (bottomColor[1] - topColor[1]) * t).round();
    final b = (topColor[2] + (bottomColor[2] - topColor[2]) * t).round();
    for (int x = 0; x < feature.width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final dist = (dx * dx + dy * dy) == 0 ? 0.0 : (dx * dx + dy * dy);
      final normDist = (dist / (glowRadius * glowRadius)).clamp(0.0, 1.0);
      final falloff = (1 - normDist) * (1 - normDist); // easeOut cuadrático
      final glow = falloff * glowStrength;
      final fr = (r + (255 - r) * glow).round().clamp(0, 255);
      final fg = (g + (255 - g) * glow).round().clamp(0, 255);
      final fb = (b + (255 - b) * glow).round().clamp(0, 255);
      feature.setPixelRgb(x, y, fr, fg, fb);
    }
  }

  const logoSize = 420;
  final logoResized = img.copyResize(src, width: logoSize, height: logoSize, interpolation: img.Interpolation.average);
  final offsetX = (feature.width - logoSize) ~/ 2;
  final offsetY = (feature.height - logoSize) ~/ 2;
  img.compositeImage(feature, logoResized, dstX: offsetX, dstY: offsetY);

  File('legal/play_feature_graphic_1024x500.png').writeAsBytesSync(img.encodePng(feature));

  print('done');
}
