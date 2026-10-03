import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawEdit(StoryIconArt a) {
  a.canvas.save();
  a.canvas.translate(24, 24);
  a.canvas.rotate(.70);

  a.shape(
    Path()
      ..moveTo(-5.5, -12)
      ..lineTo(-5.5, -17)
      ..cubicTo(-5.5, -22, 5.5, -22, 5.5, -17)
      ..lineTo(5.5, -12)
      ..close(),
    a.coral,
  );
  a.glint(
    Path()
      ..moveTo(-3, -17)
      ..quadraticBezierTo(-2.5, -19, .4, -19),
    1.7,
  );
  a.shape(
    Path()
      ..moveTo(-5.5, -9)
      ..lineTo(5.5, -9)
      ..lineTo(5.5, 11.5)
      ..quadraticBezierTo(3, 14, 0, 12)
      ..quadraticBezierTo(-3, 14, -5.5, 11.5)
      ..close(),
    a.gold,
  );
  a.shape(
    Path()
      ..moveTo(2.1, -8)
      ..lineTo(5.5, -8)
      ..lineTo(5.5, 11.5)
      ..quadraticBezierTo(4, 13, 2.1, 12.6)
      ..close(),
    Color.lerp(a.gold, a.brown, .24)!,
    outline: false,
  );
  a.glint(
    Path()
      ..moveTo(-3.1, -6)
      ..quadraticBezierTo(-3.6, 2, -3.1, 9.3),
    1.9,
  );
  a.shape(
    Path()
      ..moveTo(-5.5, 11.5)
      ..quadraticBezierTo(-2.7, 9.8, 0, 12)
      ..quadraticBezierTo(2.7, 9.8, 5.5, 11.5)
      ..lineTo(.7, 21)
      ..quadraticBezierTo(0, 22, -.7, 21)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(-2, 18)
      ..quadraticBezierTo(0, 17.2, 2, 18)
      ..lineTo(.7, 21)
      ..quadraticBezierTo(0, 22, -.7, 21)
      ..close(),
    a.ink,
  );
  a.roundRect(
    const Rect.fromLTWH(-5.8, -13.4, 11.6, 6.2),
    Color.lerp(a.sky, a.paper, .50)!,
    radius: 1.6,
  );
  a.line(const Offset(-4, -9.3), const Offset(4, -9.3), a.sky, 1.3);
  a.glint(
    Path()
      ..moveTo(-3.8, -11.6)
      ..lineTo(2.8, -11.6),
  );
  a.canvas.restore();
}
