import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';

/// Fixed fictional landmarks shared by setup and recognition practice.
class LostLandmarkPreset {
  const LostLandmarkPreset({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;
}

const lostLandmarkPresets = [
  LostLandmarkPreset(
    id: 'fountain',
    label: 'Fountain',
    description: 'A round blue fountain with water spraying upward.',
  ),
  LostLandmarkPreset(
    id: 'information_desk',
    label: 'Information desk',
    description: 'A public information desk with a worker and help sign.',
  ),
];

/// Unknown stored IDs use the same fountain fallback in setup and play.
LostLandmarkPreset resolveLostLandmark(String presetId) =>
    lostLandmarkPresets.firstWhere(
      (preset) => preset.id == presetId,
      orElse: () => lostLandmarkPresets.first,
    );

/// Code-native practice art; this is not a photo of a family's actual location.
/// The enclosing card owns its spoken label, semantics and touch target.
class LostLandmarkIllustration extends StatelessWidget {
  const LostLandmarkIllustration({
    super.key,
    required this.presetId,
    this.size = 96,
  });

  final String presetId;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LandmarkPainter(resolveLostLandmark(presetId).id),
      ),
    ),
  );
}

class _LandmarkPainter extends CustomPainter {
  const _LandmarkPainter(this.presetId);

  final String presetId;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 160, size.height / 160);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, 156, 156),
        const Radius.circular(30),
      ),
      Paint()..color = BaseboundColors.sky,
    );
    if (presetId == 'information_desk') {
      _desk(canvas);
    } else {
      _fountain(canvas);
    }
    canvas.restore();
  }

  void _fountain(Canvas canvas) {
    final stone = Paint()..color = const Color(0xFF92ACCB);
    final water = Paint()..color = const Color(0xFF55B7E8);
    canvas.drawOval(const Rect.fromLTWH(16, 121, 128, 20), stone);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(25, 102, 110, 31),
        const Radius.circular(13),
      ),
      stone,
    );
    canvas.drawOval(const Rect.fromLTWH(22, 93, 116, 27), water);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, 66, 20, 44),
        const Radius.circular(7),
      ),
      stone,
    );
    canvas.drawOval(const Rect.fromLTWH(53, 59, 54, 16), water);
    final spray = Paint()
      ..color = BaseboundColors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(80, 62)
        ..quadraticBezierTo(42, 4, 31, 78)
        ..moveTo(80, 62)
        ..quadraticBezierTo(118, 4, 129, 78)
        ..moveTo(80, 57)
        ..lineTo(80, 26),
      spray,
    );
  }

  void _desk(Canvas canvas) {
    paintBaseboundIcon(
      canvas,
      const Rect.fromLTWH(61, 30, 55, 71),
      BaseboundIconName.adult,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 84, 124, 50),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFD89761),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 81, 132, 11),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF805335),
    );
    paintBaseboundIcon(
      canvas,
      const Rect.fromLTWH(60, 96, 38, 33),
      BaseboundIconName.info,
    );
    paintBaseboundIcon(
      canvas,
      const Rect.fromLTWH(20, 14, 36, 42),
      BaseboundIconName.help,
    );
  }

  @override
  bool shouldRepaint(_LandmarkPainter oldDelegate) =>
      oldDelegate.presetId != presetId;
}
