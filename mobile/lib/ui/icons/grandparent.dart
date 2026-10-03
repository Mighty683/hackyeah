import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawGrandparent(StoryIconArt a) {
  final silver = Color.lerp(a.lavender, a.paper, .52)!;
  a.shape(
    Path()
      ..moveTo(7, 44)
      ..cubicTo(7, 34, 12, 31, 20, 31)
      ..lineTo(28, 31)
      ..cubicTo(36, 31, 41, 34, 41, 44)
      ..quadraticBezierTo(24, 47, 7, 44)
      ..close(),
    a.gold,
  );
  a.roundRect(const Rect.fromLTWH(20, 28, 8, 10), a.skin, radius: 3);
  a.shape(
    Path()
      ..moveTo(17, 32)
      ..quadraticBezierTo(20, 35, 24, 37)
      ..quadraticBezierTo(28, 35, 31, 32)
      ..lineTo(28, 41)
      ..lineTo(20, 41)
      ..close(),
    a.cream,
  );
  a.oval(const Rect.fromLTWH(10, 5, 28, 28), silver);
  a.oval(const Rect.fromLTWH(9, 19, 7, 10), a.skin);
  a.oval(const Rect.fromLTWH(32, 19, 7, 10), a.skin);
  a.shape(
    Path()
      ..moveTo(14, 15)
      ..cubicTo(17, 9, 31, 9, 34, 16)
      ..lineTo(34, 25)
      ..cubicTo(33, 32, 29, 35, 24, 35)
      ..cubicTo(19, 35, 15, 32, 14, 25)
      ..close(),
    a.skin,
  );
  a.shape(
    Path()
      ..moveTo(12, 21)
      ..cubicTo(9, 10, 15, 3, 24, 4)
      ..cubicTo(33, 3, 39, 11, 36, 21)
      ..quadraticBezierTo(31, 17, 30, 12)
      ..cubicTo(26, 17, 20, 13, 15, 18)
      ..lineTo(14, 22)
      ..close(),
    silver,
  );
  a.glint(
    Path()
      ..moveTo(15, 11)
      ..quadraticBezierTo(20, 6, 26, 8),
    1.8,
  );
  a.oval(const Rect.fromLTWH(15, 26, 5, 3), a.coral, outline: false);
  a.oval(const Rect.fromLTWH(28, 26, 5, 3), a.coral, outline: false);
  a.trace(Path()..addOval(const Rect.fromLTWH(14, 19, 9, 8)), a.brown, 1.4);
  a.trace(Path()..addOval(const Rect.fromLTWH(25, 19, 9, 8)), a.brown, 1.4);
  a.line(const Offset(23, 22), const Offset(25, 22), a.brown, 1.3);
  a.circle(18.5, 22.7, 1, a.ink, outline: false);
  a.circle(29.5, 22.7, 1, a.ink, outline: false);
  a.trace(
    Path()
      ..moveTo(24, 24)
      ..quadraticBezierTo(22, 27, 25, 27),
    a.brown,
    1,
  );
  a.trace(
    Path()
      ..moveTo(20, 29)
      ..quadraticBezierTo(24, 33, 28, 29),
    a.brown,
    1.4,
  );
  a.line(const Offset(24, 38), const Offset(24, 44), a.brown, 1);
  a.circle(26.8, 41.5, 1, a.brown, outline: false);
  a.glint(
    Path()
      ..moveTo(11, 39)
      ..quadraticBezierTo(12, 35, 16, 35),
  );
}
