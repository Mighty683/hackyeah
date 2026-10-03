import 'dart:ui';

import 'package:flame/components.dart';

/// Demo character moving toward a point selected on the neighborhood map.
class PlayerComponent extends PositionComponent {
  PlayerComponent({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2.all(34),
        anchor: Anchor.center,
      );

  static const speed = 125.0;
  final _bodyPaint = Paint()..color = const Color(0xFF2B7560);
  final _borderPaint = Paint()..color = const Color(0xFFFFFFFF);
  Vector2? _destination;

  void moveTo(Vector2 destination) {
    _destination = destination.clone();
  }

  void reset(Vector2 startPosition) {
    position.setFrom(startPosition);
    _destination = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final destination = _destination;
    if (destination == null) return;

    final distance = destination - position;
    final step = speed * dt;
    if (distance.length <= step) {
      position.setFrom(destination);
      _destination = null;
      return;
    }
    position.add(distance.normalized() * step);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    const center = Offset(17, 17);
    canvas.drawCircle(center, 17, _borderPaint);
    canvas.drawCircle(center, 13, _bodyPaint);
    final arrow = Path()
      ..moveTo(17, 8)
      ..lineTo(24, 23)
      ..lineTo(17, 20)
      ..lineTo(10, 23)
      ..close();
    canvas.drawPath(arrow, _borderPaint);
  }
}
