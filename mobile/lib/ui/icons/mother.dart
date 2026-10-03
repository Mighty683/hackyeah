import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawMother(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(11, 32)
      ..cubicTo(8, 29, 11, 23, 10.5, 18)
      ..cubicTo(9, 7, 17, 3, 24, 4)
      ..cubicTo(35, 3, 38, 12, 37, 21)
      ..cubicTo(36, 26, 41, 30, 37, 33)
      ..cubicTo(30, 36, 17, 36, 11, 32)
      ..close(),
    a.brown,
  );
  a.shape(
    Path()
      ..moveTo(6, 44)
      ..cubicTo(6, 35, 13, 33, 19, 32)
      ..lineTo(29, 32)
      ..cubicTo(36, 33, 42, 36, 42, 44)
      ..quadraticBezierTo(24, 47, 6, 44)
      ..close(),
    a.green,
  );
  a.shape(
    Path()
      ..moveTo(20, 27)
      ..lineTo(19, 33)
      ..quadraticBezierTo(24, 39, 29, 33)
      ..lineTo(28, 27)
      ..close(),
    a.skin,
  );
  a.oval(const Rect.fromLTWH(12.5, 18, 5, 7), a.skin);
  a.oval(const Rect.fromLTWH(30.5, 18, 5, 7), a.skin);
  a.shape(
    Path()
      ..moveTo(15, 14)
      ..cubicTo(15, 7, 33, 7, 33, 15)
      ..lineTo(32, 24)
      ..cubicTo(30, 33, 18, 34, 15.5, 24)
      ..close(),
    a.skin,
  );
  a.shape(
    Path()
      ..moveTo(13, 21)
      ..cubicTo(11, 12, 15, 6, 23, 6)
      ..cubicTo(33, 5, 37, 12, 34, 22)
      ..quadraticBezierTo(30, 16, 26, 11)
      ..cubicTo(23, 16, 17, 17, 15, 17)
      ..lineTo(13, 21)
      ..close(),
    a.brown,
  );
  a.oval(const Rect.fromLTWH(16.5, 23, 4.5, 2.8), a.coral, outline: false);
  a.oval(const Rect.fromLTWH(27, 23, 4.5, 2.8), a.coral, outline: false);
  a.circle(19.5, 21, 1.1, a.ink, outline: false);
  a.circle(28.5, 21, 1.1, a.ink, outline: false);
  a.trace(
    Path()
      ..moveTo(21, 26)
      ..quadraticBezierTo(24, 29, 27, 26),
    a.ink,
    1.2,
  );
  a.trace(
    Path()
      ..moveTo(17, 33)
      ..quadraticBezierTo(24, 42, 31, 33),
    a.leaf,
    1.2,
  );
  a.glint(
    Path()
      ..moveTo(14, 13)
      ..quadraticBezierTo(16, 8, 21, 8),
    1.4,
  );
  a.glint(
    Path()
      ..moveTo(10, 40)
      ..quadraticBezierTo(11, 37, 15, 36),
    1.3,
  );
}
