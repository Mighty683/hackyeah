import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

/// Makes pictured choices visible against both pale plans and detailed artwork.
/// All available choices share a steady glow; feedback supplies its own colour.
void paintSceneHighlight(
  Canvas canvas,
  void Function(Paint) drawOutline, {
  Color color = BaseboundColors.blue,
  bool subdued = false,
}) {
  Paint stroke(Color tint, double width) => Paint()
    ..color = tint
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  if (subdued) {
    drawOutline(stroke(BaseboundColors.muted, 2.5));
    return;
  }

  final neon = HSLColor.fromColor(color)
      .withSaturation(.9)
      .withLightness(.58)
      .toColor();
  drawOutline(
    stroke(neon.withValues(alpha: .55), 10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  // A dark edge keeps the glow readable on pale floors and white photos.
  drawOutline(stroke(BaseboundColors.ink.withValues(alpha: .85), 6));
  drawOutline(stroke(neon, 4));
  drawOutline(stroke(Color.lerp(neon, Colors.white, .85)!, 1.25));
}
