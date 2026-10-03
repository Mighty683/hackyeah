import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

/// Loads the bundled TAURON Arena GeoJSON snapshot.
class DemoMapRepository {
  Future<DemoMap> load() async {
    final source = await rootBundle.loadString(
      'assets/maps/tauron-arena.geojson',
    );
    return DemoMap.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}

class DemoMap {
  DemoMap({required this.bounds, required this.center, required this.features});

  factory DemoMap.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'FeatureCollection') {
      throw const FormatException('Expected a GeoJSON FeatureCollection');
    }
    final metadata = json['metadata'] as Map<String, dynamic>;
    return DemoMap(
      bounds: (json['bbox'] as List).cast<num>(),
      center: (metadata['center'] as List).cast<num>(),
      features: (json['features'] as List)
          .map(
            (feature) =>
                DemoMapFeature.fromJson(feature as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<num> bounds;
  final List<num> center;
  final List<DemoMapFeature> features;

  // Both ground axes cover 2 km: preserve a square inside the existing viewport.
  static const mapLeft = 82.0;
  static const mapTop = 12.0;
  static const mapSize = 396.0;

  Vector2 project(List<num> longitudeLatitude) => Vector2(
    mapLeft +
        (longitudeLatitude[0] - bounds[0]) / (bounds[2] - bounds[0]) * mapSize,
    mapTop +
        (bounds[3] - longitudeLatitude[1]) / (bounds[3] - bounds[1]) * mapSize,
  );

  bool contains(double latitude, double longitude) =>
      longitude >= bounds[0] &&
      longitude <= bounds[2] &&
      latitude >= bounds[1] &&
      latitude <= bounds[3];

  /// Converts map coordinates back to longitude, latitude.
  List<num> unproject(Vector2 point) => [
    bounds[0] + (point.x - mapLeft) / mapSize * (bounds[2] - bounds[0]),
    bounds[3] - (point.y - mapTop) / mapSize * (bounds[3] - bounds[1]),
  ];
}

class DemoMapFeature {
  DemoMapFeature({
    required this.id,
    required this.properties,
    required this.geometryType,
    required this.coordinates,
  });

  factory DemoMapFeature.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    return DemoMapFeature(
      id: json['id'] as String,
      properties: json['properties'] as Map<String, dynamic>,
      geometryType: geometry['type'] as String,
      coordinates: geometry['coordinates'] as List,
    );
  }

  final String id;
  final Map<String, dynamic> properties;
  final String geometryType;
  final List<dynamic> coordinates;
  String get layer => properties['layer'] as String;
}
