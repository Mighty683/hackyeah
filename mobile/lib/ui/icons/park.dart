import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawPark(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(13, 42)
      ..quadraticBezierTo(18, 34, 16, 22)
      ..lineTo(13, 17)
      ..lineTo(17, 18)
      ..lineTo(20, 25)
      ..lineTo(24, 20)
      ..lineTo(26, 22)
      ..quadraticBezierTo(19, 30, 23, 41)
      ..quadraticBezierTo(18, 40, 13, 42)
      ..close(),
    a.brown,
  );
  a.shape(
    Path()
      ..moveTo(6, 24)
      ..cubicTo(1, 20, 4, 13, 9, 12)
      ..cubicTo(8, 6, 15, 3, 20, 6)
      ..cubicTo(25, 2, 32, 7, 31, 13)
      ..cubicTo(37, 16, 35, 25, 29, 26)
      ..cubicTo(26, 30, 21, 29, 18, 27)
      ..cubicTo(12, 30, 6, 29, 6, 24)
      ..close(),
    a.leaf,
  );
  a.shape(
    Path()
      ..moveTo(7, 18)
      ..cubicTo(6, 14, 11, 12, 13, 13)
      ..cubicTo(10, 7, 17, 5, 20, 9)
      ..cubicTo(24, 5, 30, 10, 27, 15)
      ..cubicTo(32, 18, 28, 23, 23, 22)
      ..cubicTo(18, 26, 8, 24, 7, 18)
      ..close(),
    a.green,
    outline: false,
  );
  a.glint(
    Path()
      ..moveTo(12, 11)
      ..quadraticBezierTo(14, 8, 17, 9),
  );
  a.line(const Offset(18, 31), const Offset(18, 37), a.cream, 1);
  a.line(const Offset(28, 35), const Offset(27, 42), a.brown, 3);
  a.line(const Offset(41, 34), const Offset(43, 41), a.brown, 3);
  a.shape(
    Path()
      ..moveTo(26, 29)
      ..quadraticBezierTo(34, 30, 42, 27)
      ..quadraticBezierTo(44, 27, 44, 30)
      ..lineTo(44, 34)
      ..quadraticBezierTo(34, 37, 26, 35)
      ..close(),
    a.gold,
  );
  a.shape(
    Path()
      ..moveTo(25, 35)
      ..quadraticBezierTo(35, 37, 44, 33)
      ..lineTo(45, 36)
      ..quadraticBezierTo(35, 40, 25, 38)
      ..quadraticBezierTo(23, 37, 25, 35)
      ..close(),
    a.brown,
  );
  a.glint(
    Path()
      ..moveTo(28, 31)
      ..quadraticBezierTo(34, 32, 41, 30),
  );
  a.trace(
    Path()
      ..moveTo(5, 42)
      ..quadraticBezierTo(9, 39, 13, 41),
    a.green,
    2,
  );
}
