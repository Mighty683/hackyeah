import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

/// An open glass shelter and honey-coloured bench beside a bus-stop sign.
void drawBusStop(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(10, 18)
      ..lineTo(30, 17)
      ..lineTo(30, 34)
      ..quadraticBezierTo(20, 36, 10, 34)
      ..close(),
    a.sky.withValues(alpha: .65),
  );
  a.glint(
    Path()
      ..moveTo(13, 22)
      ..lineTo(17, 18.8)
      ..moveTo(20, 25)
      ..lineTo(26, 20),
    1.8,
  );
  a.line(const Offset(21, 18), const Offset(21, 30), a.blue, 1.3);
  a.line(const Offset(9, 17), const Offset(8, 40), a.brown, 2.7);
  a.line(const Offset(31, 17), const Offset(32, 40), a.brown, 2.7);
  a.line(const Offset(7, 40), const Offset(10, 40), a.brown, 2);
  a.line(const Offset(30, 40), const Offset(34, 40), a.brown, 2);
  a.line(const Offset(13, 33), const Offset(13, 38), a.brown, 2);
  a.line(const Offset(27, 33), const Offset(28, 38), a.brown, 2);
  a.roundRect(const Rect.fromLTRB(12, 27, 28, 31), a.gold, radius: 1.4);
  a.roundRect(const Rect.fromLTRB(11, 32, 30, 35), a.gold, radius: 1.4);
  a.glint(
    Path()
      ..moveTo(13, 32.8)
      ..lineTo(27, 32.8),
    1,
  );
  a.shape(
    Path()
      ..moveTo(4, 18)
      ..quadraticBezierTo(6, 14, 10, 12)
      ..quadraticBezierTo(20, 10, 29, 12)
      ..quadraticBezierTo(33, 13, 35, 17)
      ..quadraticBezierTo(21, 19, 4, 18)
      ..close(),
    a.sky,
  );
  a.trace(
    Path()
      ..moveTo(4.5, 18)
      ..quadraticBezierTo(20, 19, 34.5, 17.2),
    a.blue,
    2.4,
  );
  a.glint(
    Path()
      ..moveTo(10, 14)
      ..quadraticBezierTo(18, 12.4, 27, 14),
  );
  a.line(const Offset(40, 15), const Offset(40, 40), a.blue, 2.5);
  a.roundRect(const Rect.fromLTRB(35, 5, 45, 18), a.blue, radius: 3);
  a.roundRect(const Rect.fromLTRB(37, 7.5, 43, 14.8), a.cream, radius: 1.5);
  a.roundRect(const Rect.fromLTRB(38, 8.5, 42, 11.5), a.sky, radius: .6);
  a.circle(38.5, 14.4, .8, a.ink, outline: false);
  a.circle(41.5, 14.4, .8, a.ink, outline: false);
  a.line(const Offset(38, 40), const Offset(42, 40), a.blue, 2);
}
