import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawAddAdult(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(7, 42)
      ..quadraticBezierTo(7, 29, 16, 27)
      ..quadraticBezierTo(22, 25, 28, 28)
      ..quadraticBezierTo(35, 30, 35, 42)
      ..quadraticBezierTo(22, 46, 7, 42)
      ..close(),
    a.blue,
  );
  a.shape(
    Path()
      ..moveTo(16, 28)
      ..quadraticBezierTo(21, 31, 27, 28)
      ..lineTo(22, 39)
      ..close(),
    a.cream,
  );
  a.roundRect(const Rect.fromLTWH(18, 22, 7, 9), a.skin, radius: 3);
  a.oval(const Rect.fromLTWH(10, 5, 23, 23), a.brown);
  a.oval(const Rect.fromLTWH(10, 16, 5, 7), a.skin);
  a.oval(const Rect.fromLTWH(29, 16, 5, 7), a.skin);
  a.shape(
    Path()
      ..moveTo(14, 13)
      ..quadraticBezierTo(16, 8, 23, 10)
      ..quadraticBezierTo(28, 10, 30, 15)
      ..lineTo(30, 21)
      ..quadraticBezierTo(28, 29, 22, 29)
      ..quadraticBezierTo(14, 28, 13, 21)
      ..close(),
    a.skin,
  );
  a.shape(
    Path()
      ..moveTo(12, 17)
      ..quadraticBezierTo(8, 8, 18, 5)
      ..quadraticBezierTo(30, 2, 32, 15)
      ..quadraticBezierTo(26, 15, 24, 10)
      ..quadraticBezierTo(20, 17, 12, 17)
      ..close(),
    a.brown,
  );
  a.circle(18, 20, 1, a.ink, outline: false);
  a.circle(26, 20, 1, a.ink, outline: false);
  a.trace(
    Path()
      ..moveTo(19, 24)
      ..quadraticBezierTo(22, 26, 25, 24),
    a.brown,
    1.3,
  );
  a.line(
    const Offset(22, 38),
    const Offset(22, 43),
    a.ink.withValues(alpha: .3),
    1,
  );
  a.circle(22, 40, .8, a.gold, outline: false);
  a.glint(
    Path()
      ..moveTo(10, 36)
      ..quadraticBezierTo(10, 31, 14, 30),
  );
  a.shape(
    Path()
      ..moveTo(36, 28)
      ..quadraticBezierTo(36, 26, 38, 26)
      ..quadraticBezierTo(41, 26, 41, 28)
      ..lineTo(41, 33)
      ..lineTo(45, 33)
      ..lineTo(45, 38)
      ..lineTo(41, 38)
      ..lineTo(41, 43)
      ..quadraticBezierTo(38, 45, 36, 43)
      ..lineTo(36, 38)
      ..lineTo(31, 38)
      ..quadraticBezierTo(29, 35, 31, 33)
      ..lineTo(36, 33)
      ..close(),
    a.gold,
  );
  a.glint(
    Path()
      ..moveTo(38, 29)
      ..lineTo(38, 35)
      ..lineTo(33, 35),
    1.1,
  );
}
