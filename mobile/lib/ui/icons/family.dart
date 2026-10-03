import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawFamily(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(3, 39)
      ..cubicTo(2, 27, 7, 23, 14, 23)
      ..cubicTo(22, 23, 26, 31, 25, 43)
      ..quadraticBezierTo(12, 46, 3, 39)
      ..close(),
    a.green,
  );
  a.shape(
    Path()
      ..moveTo(23, 43)
      ..cubicTo(22, 29, 28, 23, 34, 23)
      ..cubicTo(43, 23, 46, 30, 45, 39)
      ..quadraticBezierTo(37, 46, 23, 43)
      ..close(),
    a.lavender,
  );
  a.shape(
    Path()
      ..moveTo(5, 23)
      ..cubicTo(3, 19, 5, 16, 5, 12)
      ..cubicTo(5, 1, 22, 1, 22, 12)
      ..cubicTo(22, 18, 25, 22, 21, 25)
      ..quadraticBezierTo(13, 21, 5, 23)
      ..close(),
    a.brown,
  );
  a.oval(const Rect.fromLTWH(7, 8, 14, 17), a.skin);
  a.shape(
    Path()
      ..moveTo(6, 14)
      ..cubicTo(5, 4, 21, 3, 22, 13)
      ..quadraticBezierTo(16, 13, 14, 8)
      ..quadraticBezierTo(12, 13, 6, 14)
      ..close(),
    a.brown,
  );
  a.oval(const Rect.fromLTWH(27, 8, 14, 17), a.cream);
  a.shape(
    Path()
      ..moveTo(27, 14)
      ..cubicTo(23, 5, 32, 2, 37, 5)
      ..cubicTo(42, 4, 44, 10, 40, 14)
      ..lineTo(38, 10)
      ..quadraticBezierTo(31, 13, 27, 10)
      ..close(),
    a.gold,
  );
  a.shape(
    Path()
      ..moveTo(14, 44)
      ..cubicTo(14, 34, 17, 32, 24, 32)
      ..cubicTo(31, 32, 34, 36, 34, 44)
      ..quadraticBezierTo(24, 47, 14, 44)
      ..close(),
    a.coral,
  );
  a.oval(const Rect.fromLTWH(17, 21, 14, 15), a.skin);
  a.shape(
    Path()
      ..moveTo(17, 27)
      ..cubicTo(14, 20, 20, 18, 23, 20)
      ..cubicTo(28, 17, 34, 22, 31, 27)
      ..quadraticBezierTo(27, 26, 25, 23)
      ..quadraticBezierTo(22, 26, 17, 27)
      ..close(),
    a.brown,
  );
  for (final face in [
    const Offset(14, 16),
    const Offset(34, 16),
    const Offset(24, 28),
  ]) {
    a.circle(face.dx - 2.3, face.dy, .65, a.ink, outline: false);
    a.circle(face.dx + 2.3, face.dy, .65, a.ink, outline: false);
    a.trace(
      Path()
        ..moveTo(face.dx - 1.7, face.dy + 3)
        ..quadraticBezierTo(face.dx, face.dy + 4.5, face.dx + 1.7, face.dy + 3),
      a.ink,
      1,
    );
  }
  a.trace(
    Path()
      ..moveTo(8, 33)
      ..quadraticBezierTo(9, 39, 16, 39),
    a.leaf,
    2.4,
  );
  a.trace(
    Path()
      ..moveTo(40, 33)
      ..quadraticBezierTo(39, 39, 32, 39),
    a.lavender,
    3.5,
  );
  a.glint(
    Path()
      ..moveTo(19, 39)
      ..quadraticBezierTo(20, 36, 23, 36),
  );
}
