import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../game/maps/demo_map.dart';
import '../parent/data/family_plan.dart';

/// Foreground, one-shot placement only. Never records a track in the background.
Future<SafePoint> currentLandmarkLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const LandmarkLocationException(
      'Turn on location, or choose a pin manually.',
    );
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw const LandmarkLocationException(
      'Location is unavailable. You can still choose a pin manually.',
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
      'Your location is outside the TAURON Arena demo map. Choose a demo pin manually.',
    );
  }
  return point;
}

bool mapContainsPoint(DemoMap map, SafePoint point) =>
    point.longitude >= map.bounds[0] &&
    point.longitude <= map.bounds[2] &&
    point.latitude >= map.bounds[1] &&
    point.latitude <= map.bounds[3];

class LandmarkLocationException implements Exception {
  const LandmarkLocationException(this.message);
  final String message;
}
