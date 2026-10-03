import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

/// A curious child in a favourite star shirt, ready to explore.
void drawChild(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(9, 44)
      ..cubicTo(9, 34, 15, 31, 24, 31)
      ..cubicTo(33, 31, 39, 35, 39, 44)
      ..quadraticBezierTo(24, 46, 9, 44)
      ..close(),
    a.lavender,
  );
  a.roundRect(const Rect.fromLTWH(20, 28, 8, 8), a.skin, radius: 3);
  a.oval(const Rect.fromLTWH(8.5, 16, 7, 10), a.skin);
  a.oval(const Rect.fromLTWH(32.5, 16, 7, 10), a.skin);
  a.shape(
    Path()
      ..moveTo(12, 17)
      ..cubicTo(12, 8, 36, 7, 36, 18)
      ..lineTo(35, 24)
      ..cubicTo(34, 30, 29, 33, 24, 33)
      ..cubicTo(18, 33, 13, 29, 12, 23)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(11, 22)
      ..cubicTo(6, 10, 13, 3, 23, 4)
      ..cubicTo(31, 2, 40, 9, 37, 22)
      ..quadraticBezierTo(32, 19, 32, 12)
      ..cubicTo(28, 18, 20, 18, 17, 15)
      ..quadraticBezierTo(17, 21, 11, 22)
      ..close(),
    a.brown,
  );
  a.glint(
    Path()
      ..moveTo(14, 11)
      ..quadraticBezierTo(18, 6, 25, 7),
    1.8,
  );
  a.oval(const Rect.fromLTWH(16.7, 20, 3.4, 4.8), a.ink, outline: false);
  a.oval(const Rect.fromLTWH(27.7, 20, 3.4, 4.8), a.ink, outline: false);
  a.circle(17.8, 21.1, .7, a.paper, outline: false);
  a.circle(28.8, 21.1, .7, a.paper, outline: false);
  a.oval(const Rect.fromLTWH(14, 25, 5, 2.6), a.coral, outline: false);
  a.oval(const Rect.fromLTWH(29, 25, 5, 2.6), a.coral, outline: false);
  a.trace(
    Path()
      ..moveTo(21, 27.5)
      ..quadraticBezierTo(24, 30, 27, 27.5),
    a.brown,
    1.3,
  );
  a.polygon(const [
    Offset(29, 36),
    Offset(30.1, 38.2),
    Offset(32.5, 38.6),
    Offset(30.8, 40.3),
    Offset(31.2, 42.6),
    Offset(29, 41.5),
    Offset(26.8, 42.6),
    Offset(27.2, 40.3),
    Offset(25.5, 38.6),
    Offset(27.9, 38.2),
  ], a.gold);
  a.glint(
    Path()
      ..moveTo(14, 41)
      ..quadraticBezierTo(14, 37, 17, 36),
  );
}
