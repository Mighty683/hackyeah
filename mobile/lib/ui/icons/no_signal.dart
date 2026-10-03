import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawNoSignal(StoryIconArt a) {
  a.canvas.save();
  a.canvas.translate(24, 24);
  a.canvas.rotate(-.10);
  a.canvas.translate(-24, -24);

  a.roundRect(const Rect.fromLTRB(11.5, 3.5, 36.5, 44.5), a.blue, radius: 6.5);
  a.roundRect(const Rect.fromLTRB(15, 10, 33, 35.5), a.cream, radius: 3.5);
  a.line(const Offset(21, 7), const Offset(27, 7), a.ink, 1.5);
  a.circle(24, 40, 1.9, a.cream);

  a.roundRect(
    const Rect.fromLTRB(18, 26, 21.2, 31),
    a.blue,
    radius: 1.4,
    outline: false,
  );
  a.roundRect(
    const Rect.fromLTRB(23, 21, 26.2, 31),
    a.sky,
    radius: 1.4,
    outline: false,
  );
  a.roundRect(
    const Rect.fromLTRB(28, 16, 31.2, 31),
    a.sky.withValues(alpha: .48),
    radius: 1.4,
    outline: false,
  );

  a.line(const Offset(17.5, 31), const Offset(31, 15), a.cream, 6);
  a.line(const Offset(17.5, 31), const Offset(31, 15), a.coral, 3.8);
  a.glint(
    Path()
      ..moveTo(14, 15)
      ..lineTo(14, 10)
      ..quadraticBezierTo(14, 6, 18, 6),
  );
  a.canvas.restore();
}
