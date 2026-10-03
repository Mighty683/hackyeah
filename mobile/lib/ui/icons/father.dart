import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawFather(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(6, 44)
      ..cubicTo(6, 37, 12, 33, 19, 32)
      ..lineTo(29, 32)
      ..cubicTo(37, 33, 42, 37, 42, 44)
      ..quadraticBezierTo(25, 46, 6, 44)
      ..close(),
    a.blue,
  );
  a.roundRect(const Rect.fromLTWH(19, 27, 10, 10), a.skin, radius: 4);
  a.polygon(const [
    Offset(18, 32),
    Offset(24, 37),
    Offset(18, 40),
    Offset(14, 34),
  ], a.sky);
  a.polygon(const [
    Offset(30, 32),
    Offset(24, 37),
    Offset(30, 40),
    Offset(34, 34),
  ], a.sky);
  a.line(const Offset(24, 38), const Offset(24, 45), a.sky, 1.3);
  a.oval(const Rect.fromLTWH(11, 17, 6, 8), a.skin);
  a.oval(const Rect.fromLTWH(31, 17, 6, 8), a.skin);
  a.shape(
    Path()
      ..moveTo(14, 14)
      ..cubicTo(14, 7, 34, 7, 34, 15)
      ..lineTo(33, 25)
      ..cubicTo(32, 35, 16, 35, 15, 25)
      ..close(),
    a.skin,
  );
  a.shape(
    Path()
      ..moveTo(15, 23)
      ..cubicTo(19, 27, 20, 25, 24, 25)
      ..cubicTo(28, 25, 29, 27, 33, 23)
      ..cubicTo(33, 36, 15, 36, 15, 23)
      ..close(),
    Color.lerp(a.skin, a.brown, .47)!,
    outline: false,
  );
  a.shape(
    Path()
      ..moveTo(13, 21)
      ..cubicTo(10, 14, 12, 8, 17, 7)
      ..quadraticBezierTo(16, 4, 20, 5)
      ..quadraticBezierTo(24, 2, 28, 5)
      ..cubicTo(36, 4, 37, 14, 34, 21)
      ..lineTo(31, 14)
      ..quadraticBezierTo(25, 16, 21, 11)
      ..quadraticBezierTo(19, 16, 15, 15)
      ..close(),
    a.brown,
  );
  a.trace(
    Path()
      ..moveTo(18, 18)
      ..quadraticBezierTo(20, 17, 21, 18),
    a.brown,
    1.4,
  );
  a.trace(
    Path()
      ..moveTo(27, 18)
      ..quadraticBezierTo(29, 17, 30, 18),
    a.brown,
    1.4,
  );
  a.circle(19.5, 21, 1.1, a.ink, outline: false);
  a.circle(28.5, 21, 1.1, a.ink, outline: false);
  a.oval(const Rect.fromLTWH(16, 23, 4, 2.4), a.coral, outline: false);
  a.oval(const Rect.fromLTWH(28, 23, 4, 2.4), a.coral, outline: false);
  a.trace(
    Path()
      ..moveTo(21, 27)
      ..quadraticBezierTo(24, 30, 27, 27),
    a.ink,
    1.2,
  );
  a.glint(
    Path()
      ..moveTo(16, 10)
      ..quadraticBezierTo(20, 6, 25, 7),
    1.4,
  );
  a.glint(
    Path()
      ..moveTo(10, 40)
      ..quadraticBezierTo(11, 37, 14, 36),
    1.3,
  );
}
