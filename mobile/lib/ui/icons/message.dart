import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawMessage(StoryIconArt a) {
  final note = Path()
    ..moveTo(14, 7)
    ..cubicTo(21, 5.5, 33, 6, 38, 9)
    ..cubicTo(43, 12, 43.5, 24, 40.5, 29.5)
    ..cubicTo(38, 34, 30, 35, 23, 34.5)
    ..cubicTo(19, 38.5, 14, 41, 10.5, 41)
    ..quadraticBezierTo(12.5, 36.5, 12, 32.5)
    ..cubicTo(6.5, 31, 5, 27, 5, 21)
    ..cubicTo(5, 13, 7, 8.5, 14, 7)
    ..close();
  a.shape(note, a.sky);

  a.shape(
    Path()
      ..moveTo(12, 32.5)
      ..quadraticBezierTo(18, 34.5, 23, 34.5)
      ..cubicTo(19, 38.5, 14, 41, 10.5, 41)
      ..quadraticBezierTo(12.5, 36.5, 12, 32.5)
      ..close(),
    a.blue,
  );
  a.trace(
    Path()
      ..moveTo(12, 17)
      ..quadraticBezierTo(22, 15.5, 35, 17),
    a.blue.withValues(alpha: .42),
    3.6,
  );
  a.trace(
    Path()
      ..moveTo(12, 16)
      ..quadraticBezierTo(22, 14.5, 35, 16),
    a.cream,
    3,
  );
  a.trace(
    Path()
      ..moveTo(12.5, 23)
      ..quadraticBezierTo(20, 24, 27.5, 22.5),
    a.cream,
    3,
  );
  a.glint(
    Path()
      ..moveTo(9, 13)
      ..quadraticBezierTo(10.5, 10, 15, 9.8)
      ..quadraticBezierTo(24, 8.7, 30, 10),
  );
  a.line(const Offset(14, 35.5), const Offset(13.5, 38), a.sky, 1.3);
}
