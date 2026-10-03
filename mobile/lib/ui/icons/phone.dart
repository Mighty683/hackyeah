import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawPhone(StoryIconArt a) {
  // A curved toy receiver keeps the familiar call silhouette at small sizes.
  a.shape(
    Path()
      ..moveTo(12, 5)
      ..cubicTo(7, 4, 4, 9, 5, 16)
      ..cubicTo(7, 29, 20, 42, 33, 43)
      ..cubicTo(39, 44, 43, 40, 43, 35)
      ..quadraticBezierTo(43, 32, 39, 30)
      ..lineTo(34, 28)
      ..quadraticBezierTo(31, 27, 29, 30)
      ..lineTo(26, 33)
      ..cubicTo(21, 31, 16, 26, 14, 21)
      ..lineTo(18, 18)
      ..quadraticBezierTo(21, 16, 19, 12)
      ..lineTo(16, 7)
      ..quadraticBezierTo(15, 5, 12, 5)
      ..close(),
    a.blue,
  );
  a.shape(
    Path()
      ..moveTo(11, 4.5)
      ..cubicTo(8, 4.5, 5, 7.5, 5, 11)
      ..quadraticBezierTo(5, 13, 7, 15)
      ..lineTo(12, 20)
      ..quadraticBezierTo(14, 22, 16, 20)
      ..lineTo(20, 16)
      ..quadraticBezierTo(22, 14, 20, 11)
      ..lineTo(16, 6)
      ..quadraticBezierTo(14, 4, 11, 4.5)
      ..close(),
    a.gold,
  );
  a.shape(
    Path()
      ..moveTo(32, 27)
      ..quadraticBezierTo(33.5, 25.5, 36, 27)
      ..lineTo(42, 31)
      ..quadraticBezierTo(45, 33, 43, 37)
      ..quadraticBezierTo(41, 42, 37, 43)
      ..quadraticBezierTo(35, 43.5, 33, 41)
      ..lineTo(28, 36)
      ..quadraticBezierTo(26, 34, 28, 32)
      ..close(),
    a.gold,
  );
  a.glint(
    Path()
      ..moveTo(8, 10)
      ..quadraticBezierTo(9, 6.5, 12.5, 7.5),
    2,
  );
  a.glint(
    Path()
      ..moveTo(9, 22)
      ..quadraticBezierTo(13, 32, 23, 37),
    2,
  );
  a.glint(
    Path()
      ..moveTo(32, 31)
      ..quadraticBezierTo(33.5, 28.5, 36, 30),
    1.8,
  );
  a.line(const Offset(13, 16), const Offset(16, 13), a.brown, 1.4);
  a.line(const Offset(34, 38), const Offset(38, 34), a.brown, 1.4);
}
