import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawHome(StoryIconArt a) {
  a.roundRect(const Rect.fromLTWH(31, 7, 6, 13), a.brown, radius: 1.8);
  a.roundRect(const Rect.fromLTWH(30, 6, 8, 4), a.coral, radius: 1.5);
  a.shape(
    Path()
      ..moveTo(10, 20)
      ..quadraticBezierTo(23, 7, 37, 20)
      ..lineTo(38.5, 38)
      ..quadraticBezierTo(39, 41.5, 35, 42)
      ..lineTo(12, 42)
      ..quadraticBezierTo(8.5, 41.5, 9, 38)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(4.5, 23)
      ..quadraticBezierTo(11, 18, 20.5, 7.5)
      ..quadraticBezierTo(23, 4.5, 26, 7)
      ..quadraticBezierTo(35, 16.5, 43.5, 22)
      ..quadraticBezierTo(44.5, 24, 41, 24.5)
      ..quadraticBezierTo(32, 21, 24, 13)
      ..quadraticBezierTo(16, 22, 7, 25)
      ..quadraticBezierTo(3.5, 26, 4.5, 23)
      ..close(),
    a.coral,
  );
  a.glint(
    Path()
      ..moveTo(9, 21)
      ..quadraticBezierTo(16, 15, 23, 8.5),
  );
  a.shape(
    Path()
      ..moveTo(17, 41.5)
      ..lineTo(17, 31)
      ..cubicTo(17, 23.5, 27, 23.5, 27, 31)
      ..lineTo(27, 41.5)
      ..close(),
    a.gold,
  );
  a.glint(
    Path()
      ..moveTo(19, 36)
      ..lineTo(19, 31)
      ..quadraticBezierTo(19, 28, 21.5, 27.8),
  );
  a.circle(24, 34.5, 1, a.brown, outline: false);
  a.roundRect(const Rect.fromLTWH(29.5, 26, 6.5, 8), a.blue, radius: 2);
  a.line(const Offset(32.8, 27), const Offset(32.8, 33), a.cream, 1);
  a.line(const Offset(30.5, 30), const Offset(35, 30), a.cream, 1);
  a.line(const Offset(29, 35), const Offset(37, 35), a.brown, 1.5);
  a.shape(
    Path()
      ..moveTo(5.5, 41)
      ..cubicTo(2.5, 37.5, 6, 34.5, 8.5, 36)
      ..cubicTo(8, 31.5, 14.5, 31.5, 14.5, 36)
      ..cubicTo(19, 35, 20, 40, 17, 42)
      ..quadraticBezierTo(10, 43.5, 5.5, 41)
      ..close(),
    a.green,
  );
  a.trace(
    Path()
      ..moveTo(11.5, 41)
      ..quadraticBezierTo(11, 38.5, 9, 37),
    a.leaf,
    1.2,
  );
}
