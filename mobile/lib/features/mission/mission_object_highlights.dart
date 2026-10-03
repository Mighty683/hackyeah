import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import 'mission_scene_layout.dart';

/// Traces objects in the portrait artwork, without captions or button surfaces.
class MissionObjectHighlights extends CustomPainter {
  const MissionObjectHighlights({
    required this.layout,
    required this.stepId,
    required this.choices,
    required this.selectedChoice,
    required this.rejectedChoiceIds,
    required this.visual,
  });

  final MissionSceneLayout layout;
  final String? stepId;
  final List<MissionChoice> choices;
  final MissionChoice? selectedChoice;
  final Set<String> rejectedChoiceIds;
  final MissionVisual visual;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 600);
    for (final choice in choices) {
      final target = layout.targets[choice.id];
      if (target == null) continue;
      final rejected =
          rejectedChoiceIds.contains(choice.id) ||
          (visual == MissionVisual.quiet &&
              selectedChoice != null &&
              choice.id == 'leave');
      final selected = selectedChoice?.id == choice.id;
      final color = rejected
          ? BaseboundColors.muted
          : selected
          ? (choice.isCorrect ? BaseboundColors.green : BaseboundColors.coral)
          : BaseboundColors.blue;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      _object(canvas, choice.id, target, paint);
    }
    canvas.restore();
  }

  void _object(Canvas canvas, String id, Rect target, Paint paint) {
    if (layout.family == MissionVisual.apartment) {
      _planObject(canvas, id, paint);
      return;
    }
    if (layout.family == MissionVisual.room) {
      switch (id) {
        case 'window':
          _trace(canvas, const [
            Offset(0, 9),
            Offset(53, 47),
            Offset(53, 226),
            Offset(0, 242),
          ], paint);
        case 'door':
          _trace(canvas, const [
            Offset(316, 70),
            Offset(351, 91),
            Offset(351, 343),
            Offset(316, 332),
          ], paint);
        case 'interior':
          _trace(
            canvas,
            const [
              Offset(144, 300),
              Offset(144, 94),
              Offset(246, 94),
              Offset(246, 300),
            ],
            paint,
            closed: false,
          );
      }
      return;
    }
    if (id == 'stay') {
      final feet = layout.childFeet;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(feet.dx * 400, feet.dy * 600),
          width: 66,
          height: 20,
        ),
        paint,
      );
      return;
    }
    if (layout.family == MissionVisual.quiet && id == 'leave') {
      _trace(canvas, const [
        Offset(378, 0),
        Offset(335, 25),
        Offset(335, 316),
        Offset(380, 405),
      ], paint);
      return;
    }
    if (layout.family == MissionVisual.contacts) {
      final center = switch (id) {
        'mom' => const Offset(200, 166),
        'dad' => const Offset(200, 292),
        _ => const Offset(200, 418),
      };
      canvas.drawCircle(center, 31, paint);
      return;
    }
    if (layout.family == MissionVisual.communication) {
      final bounds = id == 'call'
          ? const Rect.fromLTWH(95, 186, 42, 44)
          : const Rect.fromLTWH(95, 347, 42, 44);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, const Radius.circular(6)),
        paint,
      );
      return;
    }
    // Contacts, phone actions and outdoor landmarks are individual drawings.
    final bounds = Rect.fromLTWH(
      target.left * 400 + 4,
      target.top * 600 + 4,
      target.width * 400 - 8,
      target.height * 600 - 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(24)),
      paint,
    );
  }

  void _planObject(Canvas canvas, String id, Paint paint) {
    switch (id) {
      case 'window':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(66, 42, 78, 16),
            const Radius.circular(3),
          ),
          paint,
        );
      case 'door':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(178, 545, 52, 18),
            const Radius.circular(4),
          ),
          paint,
        );
      case 'stay':
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(202, 450),
            width: 48,
            height: 16,
          ),
          paint,
        );
      default:
        // Trace recognisable furnishings instead of drawing four button-like
        // rectangles inside the rooms. The whole room remains a tap target.
        final bounds = switch (id) {
          'living_room' => const Rect.fromLTWH(43, 128, 117, 75),
          'bedroom' => const Rect.fromLTWH(240, 78, 76, 145),
          'kitchen' => const Rect.fromLTWH(87, 421, 86, 82),
          'hallway' => const Rect.fromLTWH(184, 366, 40, 134),
          _ => Rect.zero,
        };
        canvas.drawRRect(
          RRect.fromRectAndRadius(bounds, const Radius.circular(12)),
          paint,
        );
    }
  }

  void _trace(
    Canvas canvas,
    List<Offset> points,
    Paint paint, {
    bool closed = true,
  }) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (closed) path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MissionObjectHighlights oldDelegate) => true;
}
