import 'dart:collection';
import 'dart:math' as math;

import 'package:flame/components.dart';

import 'demo_map.dart';

/// Offline pedestrian routing on bundled line geometry; access is not verified.
/// Only shared source vertices connect ways; visual crossings add no shortcuts.
class OfflineRouter {
  OfflineRouter(DemoMap map) {
    final vertices = <String, int>{};
    for (final feature in map.features.where(_allowsWalking)) {
      final lines = feature.geometryType == 'LineString'
          ? [feature.coordinates]
          : feature.coordinates.cast<List>();
      for (final line in lines) {
        int? previous;
        for (final coordinate in line) {
          final pair = (coordinate as List).cast<num>();
          final key = '${pair[0].toDouble()},${pair[1].toDouble()}';
          final current = vertices.putIfAbsent(
            key,
            () => _addNode(map.project(pair)),
          );
          if (previous != null) {
            _addSegment(previous, current, feature.properties);
          }
          previous = current;
        }
      }
    }
  }

  // About 60 m in this 2 km snapshot. Snapping never draws an off-path connector.
  static const maximumSnapDistance = 12.0;
  final _points = <Vector2>[];
  final _edges = <Map<int, double>>[];
  final _tags = <Map<int, Map<String, dynamic>>>[];
  final _incoming = <int>{};

  static bool _allowsWalking(DemoMapFeature feature) {
    if (feature.layer != 'road' ||
        !const {
          'LineString',
          'MultiLineString',
        }.contains(feature.geometryType)) {
      return false;
    }
    final tags = feature.properties;
    final foot = tags['foot'];
    final explicitFoot = const {
      'yes',
      'designated',
      'permissive',
    }.contains(foot);
    if (foot != null && !explicitFoot) return false;
    if (tags['indoor'] == 'yes' ||
        tags.containsKey('construction') ||
        tags.containsKey('foot:conditional') ||
        tags.containsKey('access:conditional')) {
      return false;
    }
    final hazard = tags['hazard'];
    if (hazard != null && hazard != 'no') return false;
    final access = tags['access'];
    if (access != null &&
        !const {'yes', 'permissive', 'designated'}.contains(access) &&
        !explicitFoot) {
      return false;
    }
    final highway = tags['highway'];
    if (highway == 'cycleway') return explicitFoot;
    return const {
      'footway',
      'path',
      'pedestrian',
      'steps',
      'living_street',
      'residential',
      'service',
      'unclassified',
      'track',
    }.contains(highway);
  }

  int _addNode(Vector2 point) {
    _points.add(point);
    _edges.add({});
    _tags.add({});
    return _points.length - 1;
  }

  // Demo preferences, not walking-time estimates or validated safety scores.
  static double _costFactor(Map<String, dynamic> tags) {
    if (tags['footway'] == 'crossing') return 1.15;
    if (tags['highway'] == 'steps') return 1.2;
    if (const {
      'footway',
      'path',
      'pedestrian',
      'cycleway',
      'track',
    }.contains(tags['highway'])) {
      return 1;
    }
    if (tags['highway'] == 'living_street') return 1.1;
    if (const {'yes', 'both', 'left', 'right'}.contains(tags['sidewalk']) ||
        tags['sidewalk:left'] == 'yes' ||
        tags['sidewalk:right'] == 'yes' ||
        tags['sidewalk:both'] == 'yes') {
      return 1.05;
    }
    return tags['sidewalk'] == 'no' || tags['sidewalk:both'] == 'no'
        ? 1.6
        : 1.35;
  }

  void _connect(int a, int b, Map<String, dynamic> tags) {
    final start = _points[a];
    final end = _points[b];
    final length = start.distanceTo(end);
    if (length == 0) return;
    final cost = length * _costFactor(tags);
    final oneWay = tags['oneway:foot'];
    if (oneWay != '-1') {
      if (cost < (_edges[a][b] ?? double.infinity)) {
        _edges[a][b] = cost;
        _tags[a][b] = tags;
      }
      _incoming.add(b);
    }
    if (!const {'yes', '1', 'true'}.contains(oneWay)) {
      if (cost < (_edges[b][a] ?? double.infinity)) {
        _edges[b][a] = cost;
        _tags[b][a] = tags;
      }
      _incoming.add(a);
    }
  }

  void _addSegment(int a, int b, Map<String, dynamic> tags) {
    // Interior samples belong only to this segment, keeping visual crossings apart.
    final start = _points[a];
    final end = _points[b];
    final count = math.max(1, (start.distanceTo(end) / 2).ceil());
    var previous = a;
    for (var step = 1; step < count; step++) {
      final node = _addNode(start + (end - start) * (step / count));
      _connect(previous, node, tags);
      previous = node;
    }
    _connect(previous, b, tags);
  }

  int? nearestNode(Vector2 point) {
    int? result;
    var distance = maximumSnapDistance;
    for (var i = 0; i < _points.length; i++) {
      if (_edges[i].isEmpty && !_incoming.contains(i)) continue;
      final candidate = point.distanceTo(_points[i]);
      if (candidate <= distance) {
        result = i;
        distance = candidate;
      }
    }
    return result;
  }

  Vector2 pointAt(int node) => _points[node].clone();

  /// A* with Euclidean distance: admissible because each preference multiplier is at least one.
  /// Returns null for distant pins or disconnected paths; no straight-line fallback.
  List<Vector2>? route(Vector2 start, Vector2 target) {
    return routeDetails(start, target)?.points;
  }

  RoutedPath? routeDetails(Vector2 start, Vector2 target) {
    final source = nearestNode(start);
    final goal = nearestNode(target);
    if (source == null || goal == null) return null;
    final costs = <int, double>{source: 0};
    final previous = <int, int>{};
    final closed = <int>{};
    final queue = SplayTreeMap<double, List<int>>();
    double heuristic(int node) => _points[node].distanceTo(_points[goal]);
    void enqueue(int node, double cost) =>
        queue.putIfAbsent(cost + heuristic(node), () => []).add(node);
    enqueue(source, 0);
    while (queue.isNotEmpty) {
      final key = queue.firstKey()!;
      final bucket = queue[key]!;
      final current = bucket.removeLast();
      if (bucket.isEmpty) queue.remove(key);
      if (!closed.add(current)) continue;
      if (current == goal) return _reconstruct(previous, current);
      for (final edge in _edges[current].entries) {
        final cost = costs[current]! + edge.value;
        if (cost >= (costs[edge.key] ?? double.infinity)) continue;
        costs[edge.key] = cost;
        previous[edge.key] = current;
        enqueue(edge.key, cost);
      }
    }
    return null;
  }

  RoutedPath _reconstruct(Map<int, int> previous, int goal) {
    final nodes = <int>[goal];
    var current = goal;
    while (previous.containsKey(current)) {
      current = previous[current]!;
      nodes.add(current);
    }
    final ordered = nodes.reversed.toList();
    return RoutedPath(
      points: ordered.map(pointAt).toList(),
      segments: [
        for (var i = 1; i < ordered.length; i++)
          Map.unmodifiable(_tags[ordered[i - 1]][ordered[i]]!),
      ],
    );
  }
}

/// One tag record per directed path segment, for local walking instructions.
class RoutedPath {
  const RoutedPath({required this.points, required this.segments});
  final List<Vector2> points;
  final List<Map<String, dynamic>> segments;
}
