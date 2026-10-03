import 'dart:math';

import '../../parent/data/family_plan.dart';

/// A parent-selected recognition point, independent of routes and safe places.
class Landmark {
  const Landmark({
    required this.id,
    required this.name,
    required this.photoName,
    required this.latitude,
    required this.longitude,
    this.isDemo = false,
    this.icon = '📍',
  });

  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';

  factory Landmark.fromJson(Map<String, dynamic> json) {
    final point = SafePoint.fromJson(json);
    final id = json['id'] as String;
    final photoName = json['photoName'] as String;
    if (!RegExp(r'^\d+_\d+$').hasMatch(id) || photoName != '$id.photo') {
      throw const FormatException('Invalid landmark photo reference');
    }
    return Landmark(
      id: id,
      name: point.name,
      icon: point.icon,
      photoName: photoName,
      latitude: point.latitude,
      longitude: point.longitude,
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String photoName;
  final double latitude;
  final double longitude;
  final bool isDemo;
  final String icon;

  SafePoint get point => SafePoint(
    name: name,
    latitude: latitude,
    longitude: longitude,
    icon: icon,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photoName': photoName,
    'latitude': latitude,
    'longitude': longitude,
    'isDemo': isDemo,
    'icon': icon,
  };
}
