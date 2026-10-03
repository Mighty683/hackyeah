import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawHallway(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(5, 10)
      ..quadraticBezierTo(5, 7, 8, 8)
      ..lineTo(41, 8)
      ..quadraticBezierTo(44, 7, 44, 10)
      ..lineTo(34, 16)
      ..lineTo(16, 16)
      ..close(),
    a.cream,
  );
  a.polygon(const [
    Offset(16, 15),
    Offset(34, 15),
    Offset(34, 31),
    Offset(16, 31),
  ], a.cream);
  a.shape(
    Path()
      ..moveTo(5, 10)
      ..lineTo(16, 15)
      ..lineTo(16, 31)
      ..lineTo(5, 40)
      ..close(),
    a.skin,
  );
  a.shape(
    Path()
      ..moveTo(44, 10)
      ..lineTo(34, 15)
      ..lineTo(34, 31)
      ..lineTo(44, 40)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(16, 31)
      ..lineTo(34, 31)
      ..lineTo(44, 40)
      ..quadraticBezierTo(45, 43, 41, 43)
      ..lineTo(8, 43)
      ..quadraticBezierTo(4, 43, 5, 40)
      ..close(),
    a.gold,
  );
  a.line(const Offset(7, 37), const Offset(16, 30), a.brown, 1.5);
  a.line(const Offset(34, 30), const Offset(42, 37), a.brown, 1.5);
  a.roundRect(const Rect.fromLTWH(19, 18, 12, 14), a.brown, radius: 2);
  a.roundRect(const Rect.fromLTWH(21, 20, 8, 11), a.gold, radius: 1);
  a.line(const Offset(23, 22), const Offset(23, 28), a.brown, .8);
  a.circle(27, 26, .8, a.brown);
  a.line(const Offset(25, 10), const Offset(25, 13), a.brown, 1);
  a.oval(const Rect.fromLTWH(22, 14, 6, 2.8), a.gold);
  a.shape(
    Path()
      ..moveTo(22, 15)
      ..quadraticBezierTo(23, 11, 25, 12)
      ..quadraticBezierTo(27, 11, 28, 15)
      ..close(),
    a.brown,
  );
  a.line(
    const Offset(21, 34),
    const Offset(18, 41),
    a.brown.withValues(alpha: .3),
    .8,
  );
  a.line(
    const Offset(29, 34),
    const Offset(33, 41),
    a.brown.withValues(alpha: .3),
    .8,
  );
  a.glint(
    Path()
      ..moveTo(10, 40)
      ..lineTo(15, 40),
  );
}
