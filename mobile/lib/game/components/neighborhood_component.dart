import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

import '../maps/demo_map.dart';

/// Real OSM geometry with a demo destination; paths are prepared once on load.
class NeighborhoodComponent extends PositionComponent with TapCallbacks {
  NeighborhoodComponent({
    required this.map,
    required this.home,
    required this.onDestinationSelected,
  }) : super(size: Vector2(560, 420)) {
    for (final feature in map.features) {
      final shape = _prepareShape(feature);
      _layers.putIfAbsent(feature.layer, () => []).add(shape);
    }
  }

  final DemoMap map;
  final Vector2 home;
  final void Function(Vector2 point) onDestinationSelected;
  final Map<String, List<_MapShape>> _layers = {};
  final _paint = Paint();
  final _label = TextPaint(
    style: const TextStyle(
      color: Color(0xFF284D40),
      fontSize: 10,
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
  void onTapDown(TapDownEvent event) {
    if (_mapRect.contains(event.localPosition.toOffset())) {
      onDestinationSelected(event.localPosition);
    }
  }

  _MapShape _prepareShape(DemoMapFeature feature) {
    final path = Path()..fillType = PathFillType.evenOdd;
    final points = <Offset>[];
    switch (feature.geometryType) {
      case 'Point':
        points.add(map.project(feature.coordinates.cast<num>()).toOffset());
      case 'LineString':
        _addLine(path, feature.coordinates, close: false);
      case 'MultiLineString':
        for (final line in feature.coordinates) {
          _addLine(path, line as List, close: false);
        }
      case 'Polygon':
        _addPolygon(path, feature.coordinates);
      case 'MultiPolygon':
        for (final polygon in feature.coordinates) {
          _addPolygon(path, polygon as List);
        }
    }
    return _MapShape(feature, path, points);
  }

  void _addPolygon(Path path, List<dynamic> rings) {
    for (final ring in rings) {
      _addLine(path, ring as List, close: true);
    }
  }

  void _addLine(Path path, List<dynamic> coordinates, {required bool close}) {
    for (var index = 0; index < coordinates.length; index++) {
      final point = map.project((coordinates[index] as List).cast<num>());
      if (index == 0) {
        path.moveTo(point.x, point.y);
      } else {
        path.lineTo(point.x, point.y);
      }
    }
    if (close) path.close();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.clipRect(_mapRect);
    _paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE8EADD);
    canvas.drawRect(_mapRect, _paint);
    for (final layer in [
      'landuse',
      'park',
      'water',
      'building',
      'road',
      'railway',
      'poi',
    ]) {
      for (final shape in _layers[layer] ?? <_MapShape>[]) {
        _drawShape(canvas, shape);
      }
    }
    canvas.restore();
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFB4C2AC);
    canvas.drawRect(_mapRect, _paint);
    _paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2B7560);
    canvas.drawCircle(home.toOffset(), 9, _paint);
    _label.render(
      canvas,
      'BASE (DEMO)',
      home + Vector2(0, -18),
      anchor: Anchor.center,
    );
    _label.render(
      canvas,
      'TAURON ARENA',
      map.project(map.center) + Vector2(0, 25),
      anchor: Anchor.center,
    );
    _label.render(canvas, 'N ↑', Vector2(40, 30), anchor: Anchor.center);
    _label.render(canvas, '2 km', Vector2(280, 414), anchor: Anchor.center);
  }

  void _drawShape(Canvas canvas, _MapShape shape) {
    final feature = shape.feature;
    final polygon = feature.geometryType.endsWith('Polygon');
    _paint
      ..style = polygon ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = _lineWidth(feature)
      ..strokeCap = StrokeCap.round
      ..color = _color(feature);
    canvas.drawPath(shape.path, _paint);
    _paint.style = PaintingStyle.fill;
    for (final point in shape.points) {
      canvas.drawCircle(point, feature.layer == 'poi' ? 1.5 : 1, _paint);
    }
  }

  Color _color(DemoMapFeature feature) {
    if (feature.id == 'way/292867512') return const Color(0xFF61A68B);
    return switch (feature.layer) {
      'park' => const Color(0xFFB9D5A2),
      'water' => const Color(0xFF9CCFD9),
      'building' => const Color(0xFFC7BBAA),
      'road' => const Color(0xFFFCFBF5),
      'railway' => const Color(0xFF91958D),
      'poi' => const Color(0xFF7D8B77),
      _ => const Color(0xFFDDE2D2),
    };
  }

  double _lineWidth(DemoMapFeature feature) {
    if (feature.layer == 'water') return 2;
    if (feature.layer != 'road') return 0.7;
    return switch (feature.properties['highway']) {
      'motorway' || 'trunk' || 'primary' => 4,
      'secondary' || 'tertiary' || 'residential' => 2.5,
      'footway' || 'path' || 'cycleway' || 'steps' => 0.8,
      _ => 1.5,
    };
  }
}

class _MapShape {
  _MapShape(this.feature, this.path, this.points);

  final DemoMapFeature feature;
  final Path path;
  final List<Offset> points;
}
