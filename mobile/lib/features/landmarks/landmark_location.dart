import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../game/navigation_location.dart';

import '../../game/maps/demo_map.dart';
import '../parent/data/family_plan.dart';

/// Foreground, one-shot placement only. Never records a track in the background.
Future<SafePoint> currentLandmarkLocation() async {
  if (kIsWeb) {
    final position = demoLocationPosition();
    return SafePoint(
      name: '',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const LandmarkLocationException(
      'Włącz lokalizację lub wybierz znacznik ręcznie.',
    );
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw const LandmarkLocationException(
      'Lokalizacja jest niedostępna. Możesz wybrać znacznik ręcznie.',
    );
  }
  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 12),
    ),
  );
  final map = await DemoMapRepository().load();
  final point = SafePoint(
    name: '',
    latitude: position.latitude,
    longitude: position.longitude,
  );
  if (!mapContainsPoint(map, point)) {
    throw const LandmarkLocationException(
      'Jesteś poza mapą demo TAURON Areny. Wybierz przykładowy znacznik ręcznie.',
    );
  }
  return point;
}

bool mapContainsPoint(DemoMap map, SafePoint point) =>
    map.contains(point.latitude, point.longitude);

class LandmarkLocationException implements Exception {
  const LandmarkLocationException(this.message);
  final String message;
}
