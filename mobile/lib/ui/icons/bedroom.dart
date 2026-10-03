import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawBedroom(StoryIconArt a) {
  a.roundRect(const Rect.fromLTWH(8, 34, 5, 10), a.brown, radius: 2);
  a.roundRect(const Rect.fromLTWH(35, 34, 5, 10), a.brown, radius: 2);
  a.shape(
    Path()
      ..moveTo(9, 29)
      ..lineTo(9, 13)
      ..cubicTo(9, 3, 16, 7, 24, 4)
      ..cubicTo(32, 7, 39, 3, 39, 13)
      ..lineTo(39, 29)
      ..close(),
    a.gold,
  );
  a.trace(
    Path()
      ..moveTo(13, 17)
      ..lineTo(13, 13)
      ..quadraticBezierTo(13, 9, 18, 10)
      ..quadraticBezierTo(24, 8, 30, 10)
      ..quadraticBezierTo(35, 9, 35, 13)
      ..lineTo(35, 17),
    a.brown.withValues(alpha: .6),
    1.1,
  );
  a.shape(
    Path()
      ..moveTo(13, 17)
      ..quadraticBezierTo(24, 15, 35, 17)
      ..lineTo(42, 33)
      ..quadraticBezierTo(44, 38, 38, 39)
      ..lineTo(10, 39)
      ..quadraticBezierTo(4, 38, 6, 33)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(15, 16)
      ..cubicTo(20, 14, 28, 14, 33, 16)
      ..quadraticBezierTo(36, 20, 33, 23)
      ..quadraticBezierTo(23, 25, 14, 23)
      ..quadraticBezierTo(11, 20, 15, 16)
      ..close(),
    a.paper,
  );
  a.shape(
    Path()
      ..moveTo(10, 25)
      ..quadraticBezierTo(21, 27, 36, 23)
      ..quadraticBezierTo(40, 28, 42, 34)
      ..quadraticBezierTo(43, 39, 37, 39)
      ..lineTo(11, 39)
      ..quadraticBezierTo(5, 39, 6, 34)
      ..close(),
    a.lavender,
  );
  a.shape(
    Path()
      ..moveTo(27, 25)
      ..quadraticBezierTo(33, 25, 36, 23)
      ..lineTo(37, 30)
      ..quadraticBezierTo(32, 29, 27, 25)
      ..close(),
    a.cream,
  );
  a.glint(
    Path()
      ..moveTo(10, 30)
      ..quadraticBezierTo(9, 34, 11, 35),
  );
  a.trace(
    Path()
      ..moveTo(20, 29)
      ..quadraticBezierTo(19, 33, 20, 35),
    a.lavender,
    1,
  );
  a.roundRect(const Rect.fromLTWH(6, 38, 36, 4), a.gold, radius: 2);
  a.glint(
    Path()
      ..moveTo(10, 39)
      ..lineTo(34, 39),
    1,
  );
}
