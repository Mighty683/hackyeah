import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

import '../maps/demo_map.dart';
import '../maps/schematic_map_scene.dart';

/// Child-facing illustrated practice map, not street or emergency navigation.
/// Nearby source geography stays recognizable without adding a wall of labels.
class NeighborhoodComponent extends PositionComponent {
  NeighborhoodComponent({required this.map})
    : _scene = SchematicMapScene(map),
      super(size: Vector2(560, 420));

  final DemoMap map;
  final SchematicMapScene _scene;
  final _paint = Paint();
  final _label = TextPaint(
    style: const TextStyle(
      color: Color(0xFF3F4C47),
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
  );
  static const _mapRect = Rect.fromLTWH(
    DemoMap.mapLeft,
    DemoMap.mapTop,
    DemoMap.mapSize,
    DemoMap.mapSize,
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final transform = canvas.getTransform();
    final scale = math.max(
      0.01,
      math.sqrt(transform[0] * transform[0] + transform[1] * transform[1]),
    );
    canvas.save();
    canvas.clipRect(_mapRect);
    _scene.paint(canvas, scale);
    _drawLabels(canvas, scale);
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 / scale
      ..color = const Color(0xFFE2D6BA);
    canvas.drawRect(_mapRect.deflate(.5 / scale), _paint);
    canvas.restore();
  }

  void _drawLabels(Canvas canvas, double scale) {
    final visible = canvas.getLocalClipBounds().intersect(_mapRect);
    if (visible.isEmpty) return;
    final landmarkRadius = _scene.illustrationRadius(scale);
    final obstacles = <Rect>[
      Rect.fromCircle(center: _scene.arena, radius: landmarkRadius),
      if (_scene.shop != null)
        Rect.fromCircle(center: _scene.shop!, radius: landmarkRadius),
    ];
    if (visible.inflate(landmarkRadius).contains(_scene.arena)) {
      obstacles.add(
        _drawLabel(
          canvas,
          'Arena',
          _labelCenters(_scene.arena, landmarkRadius + 17 / scale),
          scale,
          obstacles,
        ),
      );
    }
    if (scale < .65) return;
    _labelPlace(
      canvas,
      'Park',
      _scene.parkLabelIn(visible),
      0,
      scale,
      obstacles,
    );
    _labelPlace(canvas, 'Pond', _scene.pondLabel, 0, scale, obstacles);
    if (scale >= 2) {
      _labelPlace(
        canvas,
        'Playground',
        _scene.playgroundLabelIn(visible, scale),
        17,
        scale,
        obstacles,
      );
    }
    _labelPlace(
      canvas,
      'Shop',
      _scene.shop,
      landmarkRadius * scale + 17,
      scale,
      obstacles,
    );
  }

  void _labelPlace(
    Canvas canvas,
    String text,
    Offset? point,
    double spacing,
    double scale,
    List<Rect> obstacles,
  ) {
    if (point == null || !canvas.getLocalClipBounds().contains(point)) return;
    obstacles.add(
      _drawLabel(
        canvas,
        text,
        _labelCenters(point, spacing / scale),
        scale,
        obstacles,
        omitOnOverlap: true,
      ),
    );
  }

  List<Offset> _labelCenters(Offset center, double distance) => [
    center + Offset(0, distance),
    center - Offset(0, distance),
    center + Offset(distance + 20, 0),
    center - Offset(distance + 20, 0),
  ];

  Rect _drawLabel(
    Canvas canvas,
    String text,
    List<Offset> centers,
    double scale,
    List<Rect> obstacles, {
    bool omitOnOverlap = false,
  }) {
    final painter = _label.toTextPainter(text);
    final visible = canvas.getLocalClipBounds().intersect(_mapRect);
    final inset = visible.deflate(
      math.min(3 / scale, visible.shortestSide / 4),
    );
    final labelScale = math.max(
      scale,
      math.max(
        (painter.width + 12) / inset.width,
        (painter.height + 6) / inset.height,
      ),
    );
    final width = (painter.width + 12) / labelScale;
    final height = (painter.height + 6) / labelScale;
    Rect? chosen;
    var leastOverlap = double.infinity;
    for (final center in centers) {
      final rect = Rect.fromLTWH(
        (center.dx - width / 2).clamp(
          inset.left,
          math.max(inset.left, inset.right - width),
        ),
        (center.dy - height / 2).clamp(
          inset.top,
          math.max(inset.top, inset.bottom - height),
        ),
        width,
        height,
      );
      var overlap = 0.0;
      for (final obstacle in obstacles) {
        if (!rect.overlaps(obstacle)) continue;
        final intersection = rect.intersect(obstacle);
        overlap += intersection.width * intersection.height;
      }
      if (overlap < leastOverlap) {
        chosen = rect;
        leastOverlap = overlap;
      }
      if (overlap == 0) break;
    }
    if (omitOnOverlap && leastOverlap > 0) return Rect.zero;
    final rect = chosen!;
    canvas.save();
    canvas.translate(rect.left, rect.top);
    canvas.scale(1 / labelScale);
    _paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFFEF8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width * labelScale, height * labelScale),
        const Radius.circular(6),
      ),
      _paint,
    );
    painter.paint(canvas, const Offset(6, 3));
    canvas.restore();
    return rect;
  }
}
