import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawLivingRoom(StoryIconArt a) {
  a.roundRect(const Rect.fromLTWH(10, 34, 5, 8), a.gold, radius: 2);
  a.roundRect(const Rect.fromLTWH(33, 34, 5, 8), a.gold, radius: 2);
  a.shape(
    Path()
      ..moveTo(8, 29)
      ..lineTo(8, 17)
      ..cubicTo(8, 11, 12, 9, 18, 10)
      ..quadraticBezierTo(24, 11, 30, 10)
      ..cubicTo(37, 9, 40, 12, 40, 18)
      ..lineTo(40, 29)
      ..close(),
    a.lavender,
  );
  a.trace(
    Path()
      ..moveTo(24, 13)
      ..quadraticBezierTo(23, 19, 24, 25),
    a.ink.withValues(alpha: .19),
    1,
  );
  a.glint(
    Path()
      ..moveTo(11, 18)
      ..quadraticBezierTo(10, 12, 18, 13),
  );
  a.shape(
    Path()
      ..moveTo(28, 16)
      ..quadraticBezierTo(31, 17, 36, 16)
      ..quadraticBezierTo(35, 22, 38, 27)
      ..quadraticBezierTo(31, 29, 27, 27)
      ..quadraticBezierTo(29, 22, 28, 16)
      ..close(),
    a.gold,
  );
  a.glint(
    Path()
      ..moveTo(30, 19)
      ..quadraticBezierTo(32, 19, 34, 19),
    1,
  );
  a.roundRect(const Rect.fromLTWH(7, 27, 34, 11), a.lavender, radius: 5);
  a.roundRect(const Rect.fromLTWH(11, 25, 26, 8), a.lavender, radius: 4);
  a.line(
    const Offset(24, 27),
    const Offset(24, 31),
    a.ink.withValues(alpha: .2),
    1,
  );
  a.roundRect(const Rect.fromLTWH(4, 22, 9, 14), a.lavender, radius: 4.5);
  a.roundRect(const Rect.fromLTWH(35, 22, 9, 14), a.lavender, radius: 4.5);
  a.glint(
    Path()
      ..moveTo(6.5, 29)
      ..lineTo(6.5, 26)
      ..quadraticBezierTo(7, 24, 9, 24),
  );
  a.glint(
    Path()
      ..moveTo(37.5, 29)
      ..lineTo(37.5, 26)
      ..quadraticBezierTo(38, 24, 40, 24),
  );
  a.trace(
    Path()
      ..moveTo(14, 35)
      ..quadraticBezierTo(24, 36, 34, 35),
    a.ink.withValues(alpha: .15),
    1,
  );
}
