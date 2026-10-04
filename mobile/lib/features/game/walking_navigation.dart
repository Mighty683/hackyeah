import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../game/maps/demo_map.dart';
import '../../game/maps/offline_router.dart';
import '../landmarks/data/landmark.dart';
import 'navigation_location.dart';
import 'walking_route.dart';

export 'walking_route.dart';

/// GPS drives route progress. Selecting a pin never changes the location.
class WalkingNavigation extends ChangeNotifier {
  WalkingNavigation({required this.map, required this.location})
    : _router = OfflineRouter(map) {
    location.addListener(_update);
  }

  final DemoMap map;
  final NavigationLocation location;
  final OfflineRouter _router;
  bool isCalculating = false;
  int _calculationRevision = 0;
  Landmark? destination;
  WalkingRoute? route;
  double progress = 0;
  double joinDistance = 0;
  double destinationDistance = 0;
  bool nearPlace = false;
  String? problem;
  bool get outsideMap =>
      location.position != null &&
      !map.contains(location.position!.latitude, location.position!.longitude);

  void navigateTo(Landmark place) {
    if (place.isDemo) return;
    _cancelCalculation();
    destination = place;
    route = null;
    progress = 0;
    _update();
  }

  void stop() {
    _cancelCalculation();
    destination = null;
    route = null;
    nearPlace = false;
    problem = null;
    notifyListeners();
  }

  void _update() {
    final fix = location.position;
    final target = destination;
    nearPlace = false;
    problem = null;
    if (fix == null || !location.isPrecise || outsideMap || target == null) {
      _cancelCalculation();
      route = null;
      progress = 0;
      notifyListeners();
      return;
    }
    if (!map.contains(target.latitude, target.longitude)) {
      _cancelCalculation();
      route = null;
      problem = 'To miejsce jest poza pobraną mapą.';
      notifyListeners();
      return;
    }
    destinationDistance = Geolocator.distanceBetween(
      fix.latitude,
      fix.longitude,
      target.latitude,
      target.longitude,
    );
    nearPlace = destinationDistance <= 20 && fix.accuracy <= 20;
    final point = map.project([fix.longitude, fix.latitude]);
    final existing = route;
    if (existing != null) {
      final nearest = existing.locate(point, minimumProgress: progress - 10);
      // Retain the route and its turn instructions while on it; replan only
      // after an accurate fix is more than 25 m from the mapped path.
      if (nearest.distance <= 25) {
        progress = math.max(progress, nearest.progress);
        joinDistance = nearest.distance;
        notifyListeners();
        return;
      }
    }
    if (!isCalculating) {
      _calculate(point, map.project([target.longitude, target.latitude]));
    }
  }

  void _cancelCalculation() {
    _calculationRevision++;
    isCalculating = false;
  }

  Future<void> _calculate(Vector2 start, Vector2 target) async {
    final revision = ++_calculationRevision;
    isCalculating = true;
    route = null;
    notifyListeners();
    try {
      // Keep A* off the UI isolate so the searching screen stays responsive.
      final path = await compute(_findPath, (_router, start, target));
      if (revision != _calculationRevision) return;
      isCalculating = false;
      progress = 0;
      if (path == null) {
        problem = 'Brak połączonej trasy pieszej. Poproś dorosłego o pomoc w wyborze innego miejsca.';
        notifyListeners();
        return;
      }
      route = WalkingRoute(map, path);
      // Apply the latest GPS fix; a calculation may finish after the child moved.
      _update();
    } catch (_) {
      if (revision != _calculationRevision) return;
      isCalculating = false;
      problem = 'Nie udało się znaleźć ścieżki. Poproś dorosłego, aby spróbował ponownie.';
      notifyListeners();
    }
  }

  String get instruction {
    if (outsideMap) {
      return 'Jesteś poza tą mapą offline. Zostań z dorosłym.';
    }
    if (!location.isPrecise) return location.message;
    if (problem != null) return problem!;
    if (destination == null) {
      return 'Wybierz znane miejsce na spacer z dorosłym.';
    }
    if (nearPlace) {
      return 'Jesteś blisko miejsca: ${destination!.name}. Rozpoznajesz je?';
    }
    final current = route;
    if (current == null) return 'Szukanie trasy spaceru…';
    if (joinDistance > 15) {
      return 'Zaznaczona ścieżka jest około ${metres(joinDistance)} stąd. Znajdź ją z dorosłym.';
    }
    if (current.length - progress <= 15) {
      return 'Zaznaczona ścieżka kończy się tutaj. Poszukaj miejsca: ${destination!.name} z dorosłym.';
    }
    return current.instructionAt(progress);
  }

  double get remaining => math.max(0, (route?.length ?? 0) - progress);

  @override
  void dispose() {
    _cancelCalculation();
    location.removeListener(_update);
    super.dispose();
  }
}

RoutedPath? _findPath((OfflineRouter, Vector2, Vector2) request) =>
    request.$1.routeDetails(request.$2, request.$3);
