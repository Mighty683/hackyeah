import 'package:flutter/material.dart';

import '../../../ui/basebound_ui.dart';

/// Neutral camera and gallery line icons for photo actions.
class PhotoActionIcon extends StatelessWidget {
  const PhotoActionIcon({
    this.gallery = false,
    this.color,
    this.size = 24,
    super.key,
  });
  final bool gallery;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PhotoPainter(gallery, color)),
    ),
  );
}

class _PhotoPainter extends CustomPainter {
  const _PhotoPainter(this.gallery, this.color);
  final bool gallery;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);
    final outline = Paint()
      ..color = color ?? BaseboundColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3, 8, 26, 20),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, outline);
    if (gallery) {
      canvas.drawPath(
        Path()
          ..moveTo(5, 25)
          ..lineTo(12, 16)
          ..lineTo(17, 22)
          ..lineTo(23, 17)
          ..lineTo(28, 24),
        outline,
      );
      canvas.drawCircle(const Offset(23, 13), 2, outline);
      return;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 4, 12, 5),
        const Radius.circular(2),
      ),
      outline,
    );
    canvas.drawCircle(const Offset(16, 18), 6, outline);
    canvas.drawCircle(
      const Offset(25, 12),
      1.5,
      Paint()..color = color ?? BaseboundColors.ink,
    );
  }

  @override
  bool shouldRepaint(_PhotoPainter old) =>
      old.gallery != gallery || old.color != color;
}
