import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Foreground GPS only. No saved tracks, background service or pretend position.
abstract interface class LocationSource {
  Future<bool> serviceEnabled();
  Future<LocationPermission> permission();
  Future<LocationPermission> requestPermission();
  Stream<Position> positions();
}

class DeviceLocationSource implements LocationSource {
  @override
  Future<bool> serviceEnabled() => Geolocator.isLocationServiceEnabled();
  @override
  Future<LocationPermission> permission() => Geolocator.checkPermission();
  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();
  @override
  Stream<Position> positions() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    ),
  );
}

enum LocationState {
  off,
  waiting,
  live,
  denied,
  settingsRequired,
  disabled,
  unavailable,
  stale,
  paused,
}

class NavigationLocation extends ChangeNotifier {
  NavigationLocation({LocationSource? source, DateTime Function()? now})
    : _source = source ?? DeviceLocationSource(),
      _now = now ?? DateTime.now;

  final LocationSource _source;
  final DateTime Function() _now;
  StreamSubscription<Position>? _subscription;
  Timer? _freshness;
  int _revision = 0;
  bool _disposed = false;
  bool _wanted = false;
  LocationState state = LocationState.off;
  Position? position;
  DateTime? _startedAt;
  static const maximumAge = Duration(seconds: 30);
  static const guidanceAccuracy = 25.0;

  bool get isPrecise =>
      state == LocationState.live &&
      position != null &&
      position!.accuracy <= guidanceAccuracy;
  bool get isTracking =>
      state == LocationState.live ||
      state == LocationState.waiting ||
      state == LocationState.stale;

  String get message => switch (state) {
    LocationState.off => 'Use GPS to see where you are.',
    LocationState.waiting => 'Finding your location… Stay with your adult.',
    LocationState.live =>
      isPrecise ? 'Live GPS · accuracy about ${position!.accuracy.round()} m' : 'GPS is approximate. Wait for a clearer position before following directions.',
    LocationState.denied =>
      'Location permission was denied. You can still explore photo pins.',
    LocationState.settingsRequired =>
      'Allow location in Android app settings, then try GPS again.',
    LocationState.disabled => 'Turn on phone location, then try GPS again.',
    LocationState.unavailable =>
      'GPS is unavailable. Try again outdoors with your adult.',
    LocationState.stale => 'GPS stopped updating. Directions are paused until a fresh position arrives.',
    LocationState.paused => 'GPS is paused.',
  };

  Future<void> start({bool requestPermission = true}) async {
    if (_disposed) return;
    _wanted = true;
    final revision = ++_revision;
    _cancel();
    position = null;
    _startedAt = _now();
    state = LocationState.waiting;
    notifyListeners();
    try {
      if (!await _source.serviceEnabled()) {
        _setState(revision, LocationState.disabled);
        return;
      }
      if (!_current(revision)) return;
      var permission = await _source.permission();
      if (!_current(revision)) return;
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await _source.requestPermission();
      }
      if (!_current(revision)) return;
      if (permission == LocationPermission.deniedForever) {
        _setState(revision, LocationState.settingsRequired);
        return;
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        _setState(revision, LocationState.denied);
        return;
      }
      _subscription = _source.positions().listen(
        (fix) => _receive(revision, fix),
        onError: (Object error) => _fail(
          revision,
          error is LocationServiceDisabledException
              ? LocationState.disabled
              : LocationState.unavailable,
        ),
        onDone: () => _fail(revision, LocationState.unavailable),
      );
      _freshness = Timer.periodic(
        const Duration(seconds: 5),
        (_) => checkFreshness(),
      );
    } catch (_) {
      _fail(revision, LocationState.unavailable);
    }
  }

  bool _current(int revision) => !_disposed && revision == _revision;

  void _receive(int revision, Position fix) {
    if (!_current(revision)) return;
    final age = _now().difference(fix.timestamp);
    if (!fix.latitude.isFinite ||
        !fix.longitude.isFinite ||
        fix.latitude.abs() > 90 ||
        fix.longitude.abs() > 180 ||
        !fix.accuracy.isFinite ||
        fix.accuracy < 0 ||
        age > maximumAge ||
        age < const Duration(seconds: -5)) {
      return;
    }
    if (position != null && fix.timestamp.isBefore(position!.timestamp)) return;
    position = fix;
    state = LocationState.live;
    notifyListeners();
  }

  void checkFreshness() {
    if (_disposed || !isTracking) return;
    if (_now().difference(position?.timestamp ?? _startedAt!) > maximumAge) {
      position = null;
      state = LocationState.stale;
      notifyListeners();
    }
  }

  void _setState(int revision, LocationState next) {
    if (!_current(revision)) return;
    position = null;
    state = next;
    notifyListeners();
  }

  void _fail(int revision, LocationState next) {
    if (!_current(revision)) return;
    _revision++;
    _cancel();
    position = null;
    state = next;
    notifyListeners();
  }

  void _cancel() {
    _subscription?.cancel();
    _subscription = null;
    _freshness?.cancel();
    _freshness = null;
  }

  void pause() {
    _revision++;
    _cancel();
    position = null;
    state = _wanted ? LocationState.paused : LocationState.off;
    if (!_disposed) notifyListeners();
  }

  Future<void> resume() async {
    if (_wanted) await start(requestPermission: false);
  }

  void stop() {
    _wanted = false;
    pause();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    _cancel();
    super.dispose();
  }
}
