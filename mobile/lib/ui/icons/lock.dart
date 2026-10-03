import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawLock(StoryIconArt a) {
  final metal = Color.lerp(a.sky, a.ink, .26)!;
  a.shape(
    Path()
      ..moveTo(13, 25)
      ..lineTo(13, 16)
      ..cubicTo(13, 2, 35, 2, 35, 16)
      ..lineTo(35, 25)
      ..lineTo(29, 25)
      ..lineTo(29, 16)
      ..cubicTo(29, 9, 19, 9, 19, 16)
      ..lineTo(19, 25)
      ..close(),
    metal,
  );
  a.glint(
    Path()
      ..moveTo(15.5, 18)
      ..lineTo(15.5, 15)
      ..cubicTo(15.5, 9, 20, 6, 25, 7),
    1.7,
  );
  a.line(Offset(32, 17), Offset(32, 22), a.sky, 1.2);
  a.shape(
    Path()
      ..moveTo(14, 21)
      ..quadraticBezierTo(24, 19.5, 34, 21)
      ..quadraticBezierTo(40, 21.5, 40, 27)
      ..lineTo(39, 37.5)
      ..quadraticBezierTo(38.5, 43, 33, 43)
      ..lineTo(15, 43)
      ..quadraticBezierTo(9.5, 43, 9, 37.5)
      ..lineTo(8, 27)
      ..quadraticBezierTo(8, 22, 14, 21)
      ..close(),
    a.gold,
  );
  a.trace(
    Path()
      ..moveTo(12, 35)
      ..quadraticBezierTo(12, 40, 17, 40)
      ..lineTo(31, 40),
    a.brown.withValues(alpha: .35),
    1.5,
  );
  a.glint(
    Path()
      ..moveTo(12, 29)
      ..quadraticBezierTo(11.5, 25, 15, 24)
      ..quadraticBezierTo(19, 23.2, 23, 23.4),
    1.9,
  );
  a.shape(
    Path()
      ..moveTo(22, 32)
      ..cubicTo(18, 29, 21, 25, 24, 25.5)
      ..cubicTo(28, 25.5, 29, 30, 26, 32)
      ..lineTo(27, 36.5)
      ..quadraticBezierTo(24, 37.5, 21, 36.5)
      ..close(),
    a.ink,
    outline: false,
  );
  a.line(Offset(22.5, 28.5), Offset(23.5, 27.5), metal, 1.1);
}
