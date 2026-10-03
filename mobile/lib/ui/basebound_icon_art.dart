/// Shared brushes for the small storybook illustrations. Each icon owns its
/// drawing on a 48-unit transparent canvas; controls own their labels and focus.
library;

import 'package:flutter/material.dart';

class StoryIconArt {
  StoryIconArt(this.canvas, {this.color, this.calm = false});

  final Canvas canvas;
  final Color? color;
  final bool calm;

  Color _tone(Color value) {
    if (color != null) return Color.lerp(value, color, .72)!;
    return calm ? Color.lerp(value, const Color(0xFF687D90), .62)! : value;
  }

  Color get ink => color ?? const Color(0xFF39415C);
  Color get blue => _tone(const Color(0xFF679DD1));
  Color get sky => _tone(const Color(0xFFBFDFED));
  Color get gold => _tone(const Color(0xFFF1BD68));
  Color get cream => _tone(const Color(0xFFFFEDCE));
  Color get coral => _tone(const Color(0xFFE79683));
  Color get green => _tone(const Color(0xFF83B57C));
  Color get leaf => _tone(const Color(0xFF4F8D68));
  Color get brown => _tone(const Color(0xFFAC805E));
  Color get lavender => _tone(const Color(0xFFB4A0CB));
  Color get skin => _tone(const Color(0xFFF2C49E));
  Color get paper =>
      color == null ? const Color(0xFFFFFCF5) : color!.withValues(alpha: .9);

  Paint stroke(Color tone, [double width = 1.6]) => Paint()
    ..color = tone
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// A small tonal wash and soft outline give a painted-object appearance.
  void shape(Path path, Color tone, {bool outline = true, bool shaded = true}) {
    final bounds = path.getBounds();
    final paint = Paint()..color = tone;
    if (shaded && !bounds.isEmpty) {
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(tone, Colors.white, .18)!,
          tone,
          Color.lerp(tone, ink, .10)!,
        ],
      ).createShader(bounds);
    }
    canvas.drawPath(path, paint);
    if (outline) {
      canvas.drawPath(path, stroke(Color.lerp(tone, ink, .42)!, 1.2));
    }
  }

  void oval(Rect bounds, Color tone, {bool outline = true}) =>
      shape(Path()..addOval(bounds), tone, outline: outline);

  void circle(
    double x,
    double y,
    double radius,
    Color tone, {
    bool outline = true,
  }) => oval(
    Rect.fromCircle(center: Offset(x, y), radius: radius),
    tone,
    outline: outline,
  );

  void roundRect(
    Rect bounds,
    Color tone, {
    double radius = 4,
    bool outline = true,
  }) => shape(
    Path()..addRRect(RRect.fromRectAndRadius(bounds, Radius.circular(radius))),
    tone,
    outline: outline,
  );

  void line(Offset start, Offset end, Color tone, [double width = 1.6]) =>
      canvas.drawLine(start, end, stroke(tone, width));

  void trace(Path path, Color tone, [double width = 1.6]) =>
      canvas.drawPath(path, stroke(tone, width));

  void polygon(List<Offset> points, Color tone, {bool outline = true}) =>
      shape(Path()..addPolygon(points, true), tone, outline: outline);

  void glint(Path path, [double width = 1.4]) =>
      trace(path, paper.withValues(alpha: .76), width);
}
