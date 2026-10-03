import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawKitchen(StoryIconArt a) {
  a.roundRect(const Rect.fromLTWH(10, 39, 5, 6), a.brown, radius: 1.8);
  a.roundRect(const Rect.fromLTWH(33, 39, 5, 6), a.brown, radius: 1.8);
  a.shape(
    Path()
      ..moveTo(8, 24)
      ..lineTo(40, 24)
      ..lineTo(40, 39)
      ..quadraticBezierTo(40, 42, 36, 42)
      ..lineTo(12, 42)
      ..quadraticBezierTo(8, 42, 8, 39)
      ..close(),
    a.green,
  );
  a.roundRect(const Rect.fromLTWH(12, 30, 24, 10), a.leaf, radius: 3);
  a.roundRect(const Rect.fromLTWH(15, 32, 18, 6), a.cream, radius: 2);
  a.line(const Offset(18, 31), const Offset(30, 31), a.brown, 2.2);
  a.glint(
    Path()
      ..moveTo(18, 34)
      ..lineTo(21, 34),
    1,
  );
  for (final x in <double>[14, 24, 34]) {
    a.circle(x, 27.5, 1.5, a.cream);
  }
  a.roundRect(const Rect.fromLTWH(5, 22, 38, 3.5), a.gold, radius: 1.7);
  a.glint(
    Path()
      ..moveTo(8, 23)
      ..lineTo(38, 23),
    1,
  );
  a.roundRect(const Rect.fromLTWH(10, 14, 9, 4), a.brown, radius: 2);
  a.roundRect(const Rect.fromLTWH(29, 14, 9, 4), a.brown, radius: 2);
  a.shape(
    Path()
      ..moveTo(14, 12)
      ..lineTo(34, 12)
      ..lineTo(33, 18)
      ..quadraticBezierTo(32, 23, 27, 23)
      ..lineTo(21, 23)
      ..quadraticBezierTo(16, 23, 15, 18)
      ..close(),
    a.coral,
  );
  a.glint(
    Path()
      ..moveTo(17, 15)
      ..quadraticBezierTo(17, 19, 20, 20),
    1.6,
  );
  a.shape(
    Path()
      ..moveTo(13, 12)
      ..quadraticBezierTo(15, 8, 24, 8)
      ..quadraticBezierTo(33, 8, 35, 12)
      ..quadraticBezierTo(24, 14, 13, 12)
      ..close(),
    a.coral,
  );
  a.roundRect(const Rect.fromLTWH(21, 5, 6, 4), a.brown, radius: 2);
  a.glint(
    Path()
      ..moveTo(17, 11)
      ..quadraticBezierTo(19, 10, 22, 10),
    1,
  );
}
