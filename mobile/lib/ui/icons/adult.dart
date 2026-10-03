import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawAdult(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(13, 29)
      ..cubicTo(8, 26, 13, 22, 11, 18)
      ..cubicTo(8, 12, 13, 5, 19, 5)
      ..cubicTo(23, 1, 31, 4, 33, 8)
      ..cubicTo(39, 12, 34, 18, 37, 23)
      ..cubicTo(40, 30, 32, 32, 28, 30)
      ..close(),
    a.brown,
  );
  a.shape(
    Path()
      ..moveTo(6, 44)
      ..cubicTo(6, 34, 12, 30, 21, 29)
      ..lineTo(28, 29)
      ..cubicTo(37, 31, 42, 35, 42, 44)
      ..quadraticBezierTo(24, 47, 6, 44)
      ..close(),
    a.blue,
  );
  a.roundRect(const Rect.fromLTWH(20, 25, 9, 10), a.skin, radius: 3);
  a.shape(
    Path()
      ..moveTo(18, 31)
      ..quadraticBezierTo(24, 36, 30, 31)
      ..lineTo(27, 45)
      ..lineTo(21, 45)
      ..close(),
    a.cream,
  );
  a.polygon(const [Offset(18, 30), Offset(24, 35), Offset(19, 38)], a.paper);
  a.polygon(const [Offset(30, 30), Offset(24, 35), Offset(29, 38)], a.paper);
  a.oval(const Rect.fromLTWH(12, 16, 5, 8), a.skin);
  a.oval(const Rect.fromLTWH(31, 16, 5, 8), a.skin);
  a.shape(
    Path()
      ..moveTo(15, 13)
      ..quadraticBezierTo(24, 6, 33, 13)
      ..lineTo(32, 23)
      ..cubicTo(31, 28, 28, 31, 24, 31)
      ..cubicTo(19, 31, 16, 27, 15, 22)
      ..close(),
    a.skin,
  );
  a.shape(
    Path()
      ..moveTo(13, 18)
      ..cubicTo(10, 7, 19, 4, 25, 6)
      ..cubicTo(33, 4, 37, 12, 33, 18)
      ..quadraticBezierTo(29, 14, 28, 10)
      ..cubicTo(24, 15, 19, 11, 15, 17)
      ..close(),
    a.brown,
  );
  a.glint(
    Path()
      ..moveTo(15, 11)
      ..quadraticBezierTo(19, 7, 24, 8),
  );
  a.circle(19.5, 20, 1.05, a.ink, outline: false);
  a.circle(28.5, 20, 1.05, a.ink, outline: false);
  a.oval(const Rect.fromLTWH(16.5, 22, 4, 2), a.coral, outline: false);
  a.oval(const Rect.fromLTWH(27.5, 22, 4, 2), a.coral, outline: false);
  a.trace(
    Path()
      ..moveTo(21, 25)
      ..quadraticBezierTo(24, 28, 27, 25),
    a.ink,
    1.2,
  );
  a.line(const Offset(13, 39), const Offset(12, 44), a.sky, 1.3);
  a.line(const Offset(35, 39), const Offset(36, 44), a.sky, 1.3);
}
