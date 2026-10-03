import 'dart:async';

import 'package:do_bazy/features/game/navigation_location.dart';
import 'package:geolocator/geolocator.dart';

class FakeLocationSource implements LocationSource {
  final updates = StreamController<Position>.broadcast();
  LocationPermission allowed = LocationPermission.whileInUse;
  bool enabled = true;
  int requests = 0;
  @override
  Future<bool> serviceEnabled() async => enabled;
  @override
  Future<LocationPermission> permission() async => allowed;
  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return allowed;
  }

  @override
  Stream<Position> positions() => updates.stream;
}

Position fix(
  DateTime now, {
  double latitude = 50.005,
  double longitude = 20.001,
  double accuracy = 5,
}) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: now,
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);
