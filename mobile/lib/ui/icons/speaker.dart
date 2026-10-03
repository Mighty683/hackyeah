import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawSpeaker(StoryIconArt a) {
  a.roundRect(const Rect.fromLTWH(10, 37, 6, 5), a.brown, radius: 2);
  a.roundRect(const Rect.fromLTWH(23, 36, 5, 5), a.brown, radius: 2);
  a.shape(
    Path()
      ..moveTo(16, 7)
      ..quadraticBezierTo(29, 5, 30, 12)
      ..lineTo(30, 34)
      ..quadraticBezierTo(30, 39, 24, 39)
      ..lineTo(14, 39)
      ..close(),
    a.gold,
  );
  a.shape(
    Path()
      ..moveTo(11, 9)
      ..quadraticBezierTo(5, 9, 5, 15)
      ..lineTo(6, 33)
      ..quadraticBezierTo(6, 39, 12, 40)
      ..lineTo(23, 40)
      ..quadraticBezierTo(27, 39, 27, 34)
      ..lineTo(26, 13)
      ..quadraticBezierTo(26, 8, 21, 8)
      ..close(),
    a.blue,
  );
  a.oval(const Rect.fromLTWH(9, 18, 15, 18), a.gold);
  a.oval(const Rect.fromLTWH(11, 20, 11, 14), a.cream);
  a.oval(const Rect.fromLTWH(14, 24, 6, 7), a.blue);
  a.glint(
    Path()
      ..moveTo(12, 25)
      ..quadraticBezierTo(12, 22, 15, 21),
  );
  a.roundRect(const Rect.fromLTWH(12, 12, 8, 3), a.sky, radius: 1.5);
  a.glint(
    Path()
      ..moveTo(8, 17)
      ..lineTo(8, 13)
      ..quadraticBezierTo(8, 11, 12, 11),
  );
  a.trace(
    Path()
      ..moveTo(34, 18)
      ..quadraticBezierTo(40, 25, 34, 32),
    a.gold,
    2.8,
  );
  a.trace(
    Path()
      ..moveTo(39, 13)
      ..quadraticBezierTo(49, 25, 39, 37),
    a.coral,
    2.8,
  );
}
