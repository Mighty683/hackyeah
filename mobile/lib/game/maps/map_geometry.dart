import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';

import 'demo_map.dart';

/// Simplified source outlines for illustrated maps. Adult pin maps use raw geometry.
abstract final class MapGeometry {
  static bool isPolygon(DemoMapFeature feature) =>
      feature.geometryType == 'Polygon' ||
      feature.geometryType == 'MultiPolygon';

  static Path polygonPath(DemoMap map, DemoMapFeature feature) {
    final path = Path()..fillType = PathFillType.evenOdd;
    final polygons = feature.geometryType == 'MultiPolygon'
        ? feature.coordinates
        : [feature.coordinates];
    for (final polygon in polygons) {
      for (final ring in polygon as List) {
        _addOutline(path, _projectPoints(map, ring as List), closed: true);
      }
    }
    return path;
  }

  static Path linePath(DemoMap map, DemoMapFeature feature) {
    final path = Path();
    final lines = feature.geometryType == 'MultiLineString'
        ? feature.coordinates
        : feature.geometryType == 'LineString'
        ? [feature.coordinates]
        : const <List>[];
    for (final line in lines) {
      _addOutline(path, _projectPoints(map, line as List), closed: false);
    }
    return path;
  }

  static List<Offset> _projectPoints(DemoMap map, List coordinates) => [
    for (final point in coordinates)
      map.project((point as List).cast<num>()).toOffset(),
  ];

  static void _addOutline(
    Path path,
    List<Offset> points, {
    required bool closed,
  }) {
    if (points.length < 2) return;
    final simplified = _simplify(points, .25);
    path.moveTo(simplified.first.dx, simplified.first.dy);
    for (final point in simplified.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (closed) path.close();
  }

  /// Remove tiny source wiggles while retaining street bends and building shape.
  static List<Offset> _simplify(List<Offset> points, double tolerance) {
    final retained = {0, points.length - 1};
    final pending = [(0, points.length - 1)];
    while (pending.isNotEmpty) {
      final (start, end) = pending.removeLast();
      var farthest = tolerance;
      var split = -1;
      for (var index = start + 1; index < end; index++) {
        final distance = _segmentDistance(
          points[index],
          points[start],
          points[end],
        );
        if (distance <= farthest) continue;
        farthest = distance;
        split = index;
      }
      if (split == -1) continue;
      retained.add(split);
      pending.addAll([(start, split), (split, end)]);
    }
    final indexes = retained.toList()..sort();
    return [for (final index in indexes) points[index]];
  }

  static double _segmentDistance(Offset point, Offset start, Offset end) {
    final delta = end - start;
    if (delta.distanceSquared == 0) return (point - start).distance;
    final fraction =
        ((point.dx - start.dx) * delta.dx + (point.dy - start.dy) * delta.dy) /
        delta.distanceSquared;
    final nearest = start + delta * fraction.clamp(0.0, 1.0);
    return (point - nearest).distance;
  }
}
