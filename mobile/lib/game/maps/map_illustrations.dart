import 'dart:math' as math;

import 'package:flutter/painting.dart';

class MapIllustrations {
  final _paint = Paint();

  void paintTree(Canvas canvas, Offset point) {
    canvas.save();
    canvas.translate(point.dx, point.dy);
    canvas.scale(.3);
    _fill(const Color(0xFF8AA865));
    canvas.drawOval(const Rect.fromLTRB(-9, -3, 9, 3), _paint);
    _stroke(const Color(0xFF95704B), 3);
    canvas.drawLine(Offset.zero, const Offset(0, -11), _paint);
    _fill(const Color(0xFF7AAA53));
    canvas.drawCircle(const Offset(0, -13), 9, _paint);
    _fill(const Color(0xFF90BC64));
    canvas.drawCircle(const Offset(-4, -15), 5, _paint);
    canvas.restore();
  }

  void paintPondRipples(Canvas canvas, Path pond) {
    final bounds = pond.getBounds();
    if (bounds.isEmpty) return;
    _stroke(const Color(0xFFDDF6F8), .5);
    for (final dy in [-5.0, 4.0]) {
      final center = bounds.center + Offset(0, dy);
      canvas.drawLine(
        center - const Offset(7, 0),
        center + const Offset(7, 0),
        _paint,
      );
    }
  }

  double illustrationRadius(double scale) =>
      math.max(12, math.min(18 / scale, 22));

  void paintArena(Canvas canvas, Offset arena, double scale) {
    final radius = illustrationRadius(scale);
    canvas.save();
    canvas.translate(arena.dx, arena.dy);
    canvas.scale(radius / 23);
    _fill(const Color(0xFFB9ACCE));
    canvas.drawOval(const Rect.fromLTRB(-24, -13, 24, 20), _paint);
    _fill(const Color(0xFFB9B0DE));
    canvas.drawOval(const Rect.fromLTRB(-24, -20, 24, 12), _paint);
    _stroke(const Color(0xFF786994), 1.5);
    canvas.drawOval(const Rect.fromLTRB(-24, -20, 24, 12), _paint);
    _fill(const Color(0xFFEDE7F7));
    canvas.drawOval(const Rect.fromLTRB(-18, -15, 18, 6), _paint);
    _fill(const Color(0xFF9B8EC3));
    canvas.drawOval(const Rect.fromLTRB(-12, -11, 12, 2), _paint);
    _stroke(const Color(0xFF786994), 2);
    for (final x in [-15.0, -7.0, 7.0, 15.0]) {
      canvas.drawLine(Offset(x, 10), Offset(x, 16), _paint);
    }
    _fill(const Color(0xFF63527E));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-4, 9, 4, 20),
        const Radius.circular(2),
      ),
      _paint,
    );
    canvas.restore();
  }

  void paintShop(Canvas canvas, Offset center, double scale) {
    final radius = illustrationRadius(scale);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(radius / 23);
    _fill(const Color(0xFFE8D9B9));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-23, -13, 23, 19),
        const Radius.circular(4),
      ),
      _paint,
    );
    _fill(const Color(0xFFFFF9E8));
    canvas.drawRect(const Rect.fromLTRB(-19, -6, 19, 16), _paint);
    _fill(const Color(0xFFBBDDE0));
    canvas.drawRect(const Rect.fromLTRB(-15, -2, -2, 11), _paint);
    canvas.drawRect(const Rect.fromLTRB(6, -2, 15, 16), _paint);
    _fill(const Color(0xFFDD8269));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-25, -17, 25, -5),
        const Radius.circular(3),
      ),
      _paint,
    );
    _fill(const Color(0xFFFFF3D4));
    for (final x in [-16.0, -2.0, 12.0]) {
      canvas.drawRect(Rect.fromLTWH(x, -17, 7, 12), _paint);
    }
    _stroke(const Color(0xFF9C6851), 1.5);
    canvas.drawLine(const Offset(-25, -5), const Offset(25, -5), _paint);
    canvas.restore();
  }

  void _fill(Color color) {
    _paint
      ..style = PaintingStyle.fill
      ..color = color;
  }

  void _stroke(Color color, double width) {
    _paint
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }
}
