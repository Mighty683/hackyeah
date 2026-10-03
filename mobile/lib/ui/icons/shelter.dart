import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawShelter(StoryIconArt a) {
  final stone = Color.lerp(a.cream, a.brown, .23)!;
  final mortar = Color.lerp(stone, a.brown, .4)!;
  a.shape(
    Path()
      ..moveTo(8, 18)
      ..quadraticBezierTo(6, 28, 7, 39)
      ..quadraticBezierTo(7, 41, 11, 41)
      ..lineTo(37, 41)
      ..quadraticBezierTo(41, 41, 41, 38)
      ..lineTo(40, 18)
      ..close(),
    stone,
  );
  a.shape(
    Path()
      ..moveTo(35, 18)
      ..lineTo(40, 18)
      ..lineTo(41, 38)
      ..quadraticBezierTo(41, 41, 37, 41)
      ..lineTo(35, 41)
      ..close(),
    Color.lerp(stone, a.brown, .25)!,
    outline: false,
  );
  a.line(const Offset(8, 27), const Offset(16, 27), mortar, 1);
  a.line(const Offset(8, 34), const Offset(15, 34), mortar, 1);
  a.line(const Offset(12, 21), const Offset(12, 27), mortar, 1);
  a.line(const Offset(35, 28), const Offset(40, 28), mortar, 1);
  a.line(const Offset(36, 35), const Offset(40, 35), mortar, 1);
  a.shape(
    Path()
      ..moveTo(16, 40)
      ..lineTo(16, 29)
      ..cubicTo(16, 18, 33, 18, 33, 29)
      ..lineTo(33, 40)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(20, 40)
      ..lineTo(20, 29)
      ..cubicTo(20, 23, 29, 23, 29, 29)
      ..lineTo(29, 40)
      ..close(),
    a.blue,
  );
  a.trace(
    Path()
      ..moveTo(21, 38)
      ..lineTo(21, 29)
      ..quadraticBezierTo(21, 26, 24, 26),
    a.sky,
    1.3,
  );
  a.circle(26.5, 33.5, .85, a.gold, outline: false);
  a.roundRect(const Rect.fromLTWH(14, 39, 21, 4), stone, radius: 1.5);
  a.shape(
    Path()
      ..moveTo(5, 18)
      ..lineTo(11, 9)
      ..quadraticBezierTo(13, 7, 17, 8)
      ..lineTo(34, 8)
      ..quadraticBezierTo(37, 8, 38, 11)
      ..lineTo(43, 18)
      ..quadraticBezierTo(43, 21, 39, 21)
      ..lineTo(8, 21)
      ..quadraticBezierTo(4, 21, 5, 18)
      ..close(),
    a.leaf,
  );
  a.glint(
    Path()
      ..moveTo(10, 17)
      ..lineTo(14, 11)
      ..quadraticBezierTo(17, 10, 22, 11),
  );
}
