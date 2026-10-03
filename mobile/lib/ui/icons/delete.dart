import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawDelete(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(11, 17)
      ..lineTo(37, 17)
      ..lineTo(34.4, 37.4)
      ..quadraticBezierTo(33.9, 41.3, 29.6, 41.7)
      ..quadraticBezierTo(24, 42.4, 18.4, 41.6)
      ..quadraticBezierTo(14.2, 41.1, 13.7, 37.2)
      ..close(),
    a.blue,
  );
  a.trace(
    Path()
      ..moveTo(17.2, 23)
      ..quadraticBezierTo(17.6, 30.7, 18.5, 36.5),
    a.sky,
    2.5,
  );
  a.line(const Offset(24, 23.5), const Offset(24, 37.2), a.sky, 2.5);
  a.trace(
    Path()
      ..moveTo(30.9, 23)
      ..quadraticBezierTo(30.6, 30.7, 29.7, 36.5),
    a.sky,
    2.5,
  );
  a.shape(
    Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(17, 14)
      ..lineTo(17.7, 9.1)
      ..quadraticBezierTo(18.2, 6.3, 21.2, 6.3)
      ..lineTo(26.8, 6.3)
      ..quadraticBezierTo(29.8, 6.3, 30.3, 9.1)
      ..lineTo(31, 14)
      ..close()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(21, 9, 6, 5),
          const Radius.circular(1.5),
        ),
      ),
    a.gold,
  );
  a.shape(
    Path()
      ..moveTo(8.3, 15.7)
      ..quadraticBezierTo(8.7, 13.3, 12.5, 13)
      ..quadraticBezierTo(24, 11.6, 35.5, 13)
      ..quadraticBezierTo(39.4, 13.3, 39.7, 15.7)
      ..lineTo(39.8, 18.5)
      ..quadraticBezierTo(24, 20.2, 8.2, 18.5)
      ..close(),
    a.gold,
  );
  a.glint(
    Path()
      ..moveTo(12.2, 15.2)
      ..quadraticBezierTo(20, 14.3, 29.7, 14.8),
  );
}
