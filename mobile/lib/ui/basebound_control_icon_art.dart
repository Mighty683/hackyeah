import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'basebound_icon_name.dart';

void paintBaseboundControlIcon(
  Canvas canvas,
  BaseboundIconName name, {
  Color? color,
  bool calm = false,
}) => _ControlIconDrawing(canvas, name, color, calm).paint();

class _ControlIconDrawing {
  _ControlIconDrawing(this.canvas, this.name, this.override, this.calm);

  final Canvas canvas;
  final BaseboundIconName name;
  final Color? override;
  final bool calm;

  Color get ink => override ?? const Color(0xFF112568);
  Color get blue =>
      override ?? (calm ? const Color(0xFF536184) : const Color(0xFF1677FF));
  Color get warm =>
      override ?? (calm ? const Color(0xFFA1B0C5) : const Color(0xFFFFBF46));
  Color get green =>
      override ?? (calm ? const Color(0xFF536184) : const Color(0xFF28A36A));
  Color get light =>
      override?.withValues(alpha: .22) ??
      (calm ? const Color(0xFFE4EBF4) : const Color(0xFFE6F2FF));

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(Color color, [double width = 1.8]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void paint() {
    switch (name) {
      case BaseboundIconName.back:
      case BaseboundIconName.next:
      case BaseboundIconName.up:
      case BaseboundIconName.down:
        _arrow();
      case BaseboundIconName.replay:
        _replay();
      case BaseboundIconName.play:
        _circle(12, 12, 10, light);
        _polygon([
          const Offset(9, 6),
          const Offset(19, 12),
          const Offset(9, 18),
        ], blue);
      case BaseboundIconName.plus:
      case BaseboundIconName.minus:
        _circle(12, 12, 10, light);
        _line(6, 12, 18, 12, blue, 2.6);
        if (name == BaseboundIconName.plus) _line(12, 6, 12, 18, blue, 2.6);
      case BaseboundIconName.fitMap:
        _rect(7, 7, 10, 10, light, radius: 2);
        for (final angle in [0.0, math.pi / 2, math.pi, math.pi * 1.5]) {
          canvas.save();
          canvas.translate(12, 12);
          canvas.rotate(angle);
          _polyline(
            [const Offset(-3, -9), const Offset(-9, -9), const Offset(-9, -3)],
            blue,
            2.2,
          );
          canvas.restore();
        }
      case BaseboundIconName.info:
        _circle(12, 12, 10, light);
        _circle(12, 7, 1.25, blue);
        _line(12, 11, 12, 17, blue, 2.5);
        _line(10, 17, 14, 17, blue, 2);
      case BaseboundIconName.check:
        _circle(12, 12, 10, override == null ? green : light);
        _polyline(
          [
            const Offset(6.5, 12),
            const Offset(10.5, 16),
            const Offset(17.5, 8),
          ],
          override ?? Colors.white,
          2.6,
        );
      case BaseboundIconName.cross:
        _circle(12, 12, 10, light);
        final cross = override ?? (calm ? ink : const Color(0xFFE54949));
        _line(8, 8, 16, 16, cross, 2.7);
        _line(16, 8, 8, 16, cross, 2.7);
      case BaseboundIconName.birthday:
        _birthday();
      case BaseboundIconName.map:
        _map();
      case BaseboundIconName.pin:
      case BaseboundIconName.addPlace:
        _pin();
      case BaseboundIconName.alarm:
        _alarm();
      case BaseboundIconName.heart:
        _heart();
      case BaseboundIconName.unresponsive:
        _unresponsive();
      case BaseboundIconName.lost:
        _map();
        _circle(17, 15, 5.7, warm);
        _question(17, 15, blue, .58);
      case BaseboundIconName.unsure:
        _circle(12, 12, 10, light);
        _question(12, 12, blue, 1);
      case BaseboundIconName.stay:
        _stay();
      case BaseboundIconName.protectHead:
        _protectHead();
      case BaseboundIconName.badge:
        _badge();
      case BaseboundIconName.sun:
        _sun();
      default:
        return;
    }
  }

  void _circle(double x, double y, double radius, Color color) =>
      canvas.drawCircle(Offset(x, y), radius, _fill(color));

  void _line(
    double x1,
    double y1,
    double x2,
    double y2,
    Color color, [
    double width = 1.8,
  ]) => canvas.drawLine(Offset(x1, y1), Offset(x2, y2), _stroke(color, width));

  void _rect(
    double x,
    double y,
    double width,
    double height,
    Color color, {
    double radius = 2,
    Color? outline,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      Radius.circular(radius),
    );
    canvas.drawRRect(rect, _fill(color));
    if (outline != null) canvas.drawRRect(rect, _stroke(outline, 1.5));
  }

  Path _points(List<Offset> points, {bool close = false}) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (close) path.close();
    return path;
  }

  void _polygon(List<Offset> points, Color color) =>
      canvas.drawPath(_points(points, close: true), _fill(color));

  void _polyline(List<Offset> points, Color color, [double width = 1.8]) =>
      canvas.drawPath(_points(points), _stroke(color, width));

  void _arrow() {
    _circle(12, 12, 10.5, light);
    canvas.save();
    canvas.translate(12, 12);
    canvas.rotate(switch (name) {
      BaseboundIconName.back => math.pi,
      BaseboundIconName.up => -math.pi / 2,
      BaseboundIconName.down => math.pi / 2,
      _ => 0,
    });
    _line(-5.5, 0, 5.5, 0, blue, 2.3);
    _polyline(
      [const Offset(1, -5), const Offset(6, 0), const Offset(1, 5)],
      blue,
      2.3,
    );
    canvas.restore();
  }

  void _replay() {
    _circle(12, 12, 10.5, light);
    canvas.drawPath(
      Path()
        ..moveTo(19.5, 10)
        ..cubicTo(18, 4, 11, 2, 6, 7)
        ..cubicTo(1, 12, 5, 20, 12, 20)
        ..quadraticBezierTo(17, 20, 19, 16),
      _stroke(blue, 2.2),
    );
    _polygon([
      const Offset(20.5, 3.5),
      const Offset(20.5, 11),
      const Offset(13.5, 9),
    ], blue);
  }

  void _birthday() {
    _rect(3, 10, 18, 11, blue, radius: 3);
    _rect(3, 10, 18, 4, warm, radius: 2);
    _line(12, 5, 12, 10, ink, 2);
    canvas.drawPath(
      Path()
        ..moveTo(12, 0)
        ..quadraticBezierTo(6, 6, 12, 6)
        ..quadraticBezierTo(17, 6, 12, 0),
      _fill(warm),
    );
    _line(3, 21, 21, 21, ink, 1.6);
  }

  void _map() {
    final paper = [
      const Offset(2, 5),
      const Offset(8, 2),
      const Offset(16, 5),
      const Offset(22, 2),
      const Offset(22, 19),
      const Offset(16, 22),
      const Offset(8, 19),
      const Offset(2, 22),
    ];
    _polygon(paper, light);
    canvas.drawPath(_points(paper, close: true), _stroke(blue, 1.3));
    _line(8, 3, 8, 19, blue, 1);
    _line(16, 5, 16, 21, blue, 1);
    _polyline(
      [
        const Offset(4, 16),
        const Offset(10, 10),
        const Offset(14, 14),
        const Offset(20, 8),
      ],
      warm,
      2,
    );
  }

  void _pin() {
    canvas.drawOval(const Rect.fromLTWH(5, 19, 14, 4), _fill(light));
    canvas.drawPath(
      Path()
        ..moveTo(12, 22)
        ..cubicTo(10, 19, 4, 14, 4, 9)
        ..cubicTo(4, -1, 20, -1, 20, 9)
        ..cubicTo(20, 14, 14, 19, 12, 22),
      _fill(blue),
    );
    _circle(12, 8.5, 3.5, warm);
    if (name == BaseboundIconName.addPlace) {
      _circle(18, 17, 5.5, warm);
      _line(15, 17, 21, 17, blue, 1.8);
      _line(18, 14, 18, 20, blue, 1.8);
    }
  }

  void _alarm() {
    _circle(12, 4, 2, warm);
    canvas.drawPath(
      Path()
        ..moveTo(5, 17)
        ..lineTo(7, 14)
        ..lineTo(7, 10)
        ..cubicTo(7, 3, 17, 3, 17, 10)
        ..lineTo(17, 14)
        ..lineTo(19, 17)
        ..close(),
      _fill(blue),
    );
    _line(9, 20, 15, 20, warm, 2.8);
    canvas.drawArc(
      const Rect.fromLTWH(1, 6, 5, 8),
      math.pi * .65,
      math.pi * .7,
      false,
      _stroke(blue, 1.5),
    );
    canvas.drawArc(
      const Rect.fromLTWH(18, 6, 5, 8),
      -math.pi * .35,
      math.pi * .7,
      false,
      _stroke(blue, 1.5),
    );
  }

  void _heart() {
    final heart = Path()
      ..moveTo(12, 21)
      ..cubicTo(2, 14, -1, 9, 3, 5)
      ..cubicTo(6, 2, 10, 4, 12, 7)
      ..cubicTo(14, 4, 18, 2, 21, 5)
      ..cubicTo(25, 9, 22, 14, 12, 21);
    canvas.drawPath(
      heart,
      _fill(override ?? (calm ? blue : const Color(0xFFF37985))),
    );
    canvas.drawPath(
      Path()
        ..moveTo(5, 8)
        ..quadraticBezierTo(7, 6, 9, 8),
      _stroke(override ?? Colors.white, 1.5),
    );
  }

  void _unresponsive() {
    _line(2, 21, 22, 21, ink, 1.5);
    _circle(5, 15.5, 3.5, warm);
    _rect(8, 13, 13, 6, blue, radius: 3);
    _line(4, 15, 6, 15, ink, .8);
    _line(11, 11, 13, 8, blue, 1.4);
    _line(16, 10, 17, 6, blue, 1.4);
  }

  void _question(double x, double y, Color color, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    canvas.drawPath(
      Path()
        ..moveTo(-4, -4)
        ..cubicTo(-4, -9, 5, -9, 5, -4)
        ..cubicTo(5, -1, 0, -1, 0, 2),
      _stroke(color, 2.2),
    );
    _circle(0, 6, 1.2, color);
    canvas.restore();
  }

  void _stay() {
    _circle(12, 12, 10.5, light);
    _circle(12, 6, 3, warm);
    _rect(9, 10, 6, 7, blue, radius: 2);
    _polyline(
      [const Offset(8, 15), const Offset(4, 19), const Offset(15, 20)],
      blue,
      2.5,
    );
    _polyline(
      [const Offset(16, 15), const Offset(20, 19), const Offset(9, 20)],
      blue,
      2.5,
    );
  }

  void _protectHead() {
    _rect(6, 15, 12, 7, blue, radius: 4);
    _circle(12, 12, 4, warm);
    _polyline(
      [const Offset(5, 17), const Offset(4, 8), const Offset(10, 5)],
      blue,
      3.5,
    );
    _polyline(
      [const Offset(19, 17), const Offset(20, 8), const Offset(14, 5)],
      blue,
      3.5,
    );
    _line(9, 5, 12, 7, warm, 2.6);
    _line(15, 5, 12, 7, warm, 2.6);
    _circle(10.5, 12, .6, ink);
    _circle(13.5, 12, .6, ink);
  }

  void _badge() {
    _polygon([
      const Offset(6, 13),
      const Offset(5, 23),
      const Offset(10, 20),
      const Offset(13, 22),
      const Offset(14, 13),
    ], warm);
    _polygon([
      const Offset(13, 13),
      const Offset(13, 22),
      const Offset(17, 20),
      const Offset(21, 22),
      const Offset(19, 12),
    ], warm);
    _circle(12, 9, 8.5, override == null ? green : light);
    _polyline(
      [const Offset(7, 9), const Offset(11, 13), const Offset(17, 5)],
      override ?? Colors.white,
      2,
    );
  }

  void _sun() {
    _circle(12, 12, 5.5, warm);
    _circle(10, 11, .65, blue);
    _circle(14, 11, .65, blue);
    canvas.drawArc(
      const Rect.fromLTWH(9.5, 10, 5, 5),
      .3,
      2.5,
      false,
      _stroke(blue, .9),
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      _line(
        12 + math.cos(angle) * 8.5,
        12 + math.sin(angle) * 8.5,
        12 + math.cos(angle) * 10.5,
        12 + math.sin(angle) * 10.5,
        warm,
        2,
      );
    }
  }
}
