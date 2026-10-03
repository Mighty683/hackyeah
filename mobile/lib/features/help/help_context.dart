import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../game/navigation_location.dart';
import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';

/// Foreground context for help, never evidence of safety or being indoors.
/// Saved places and phone positions stay on the device; no track is retained.
class HelpContext extends ChangeNotifier {
  HelpContext({
    NavigationLocation? location,
    LocationSource? source,
    Future<FamilyPlan> Function()? loadPlan,
    DateTime Function()? now,
  }) : assert(location == null || source == null),
       _location = location ?? NavigationLocation(source: source, now: now),
       _ownsLocation = location == null,
       _loadPlan = loadPlan ?? FamilyPlanRepository().load,
       _now = now ?? DateTime.now {
    _location.addListener(_changed);
  }

  static const nearbyRadiusMeters = 50.0;

  final NavigationLocation _location;
  final bool _ownsLocation;
  final Future<FamilyPlan> Function() _loadPlan;
  final DateTime Function() _now;
  Future<void>? _planLoad;
  List<SafePoint> _places = const [];
  bool _active = false;
  bool _disposed = false;

  /// Only a nearby familiar-place hint; it cannot establish a safe destination.
  String? get nearbyPlaceName {
    final fix = _location.position;
    if (!_active || !_location.isPrecise || fix == null) return null;
    final age = _now().difference(fix.timestamp);
    if (age > NavigationLocation.maximumAge ||
        age < const Duration(seconds: -5)) {
      return null;
    }
    SafePoint? nearest;
    var nearestDistance = double.infinity;
    for (final place in _places) {
      final distance = Geolocator.distanceBetween(
        fix.latitude,
        fix.longitude,
        place.latitude,
        place.longitude,
      );
      // Keep the reported uncertainty inside the nearby radius as well.
      if (distance + fix.accuracy <= nearbyRadiusMeters &&
          distance < nearestDistance) {
        nearest = place;
        nearestDistance = distance;
      }
    }
    return nearest?.name.trim();
  }

  /// Starts without a permission prompt or waiting for a GPS fix.
  Future<void> start() async {
    if (_disposed) return;
    _active = true;
    await Future.wait([
      _location.start(requestPermission: false),
      _planLoad ??= _loadPlaces(),
    ]);
  }

  Future<void> _loadPlaces() async {
    try {
      final plan = await _loadPlan();
      if (_disposed) return;
      _places = plan.safePoints
          .where((place) => !place.isDemo && place.name.trim().isNotEmpty)
          .toList(growable: false);
      _changed();
    } catch (_) {
      // Help remains usable when family records cannot be read.
    }
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void pause() {
    if (_disposed) return;
    _active = false;
    _location.pause();
  }

  /// The next foreground session always obtains a fresh position.
  Future<void> resume() => start();

  @override
  void dispose() {
    _disposed = true;
    _active = false;
    _location.removeListener(_changed);
    if (_ownsLocation) {
      _location.dispose();
    } else {
      _location.stop();
    }
    super.dispose();
  }
}
