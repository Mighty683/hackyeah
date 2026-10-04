import 'dart:async';

import 'package:do_bazy/features/game/navigation_location.dart';
import 'package:do_bazy/features/game/walking_navigation.dart';
import 'package:do_bazy/features/landmarks/data/landmark.dart';
import 'package:do_bazy/game/maps/demo_map.dart';
import 'package:do_bazy/game/maps/offline_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'fake_location_source.dart';

DemoMap roadMap() => DemoMap(
  bounds: [20, 50, 20.02, 50.02],
  center: [20.01, 50.01],
  features: [
    DemoMapFeature(
      id: 'path',
      properties: {'layer': 'road', 'highway': 'footway', 'name': 'Park path'},
      geometryType: 'LineString',
      coordinates: [
        [20.001, 50.005],
        [20.01, 50.005],
        [20.01, 50.015],
        [20.018, 50.015],
      ],
    ),
  ],
);

const target = Landmark(
  id: '1_1',
  name: 'Biblioteka',
  photoName: '1_1.photo',
  latitude: 50.015,
  longitude: 20.018,
);

void main() {
  late FakeLocationSource source;
  late NavigationLocation location;
  late WalkingNavigation navigation;
  late DateTime now;
  setUp(() {
    now = DateTime.utc(2026, 10, 3, 12);
    source = FakeLocationSource();
    location = NavigationLocation(source: source, now: () => now);
    navigation = WalkingNavigation(map: roadMap(), location: location);
  });
  tearDown(() async {
    navigation.dispose();
    location.dispose();
    await source.updates.close();
  });

  Future<void> emit(Position position) async {
    source.updates.add(position);
    await Future<void>.delayed(Duration.zero);
    if (navigation.isCalculating) {
      final completed = Completer<void>();
      void listen() {
        if (!navigation.isCalculating && !completed.isCompleted) {
          completed.complete();
        }
      }

      navigation.addListener(listen);
      await completed.future.timeout(const Duration(seconds: 5));
      navigation.removeListener(listen);
    }
  }

  test(
    'only received GPS fixes set position and advance walking guidance',
    () async {
      navigation.navigateTo(target);
      expect(location.position, isNull);
      expect(navigation.route, isNull);
      await location.start();
      expect(location.position, isNull);
      await emit(fix(now));
      expect(navigation.route, isNotNull);
      final initial = location.position;
      final firstRoute = navigation.route;
      navigation.navigateTo(target);
      expect(
        location.position,
        same(initial),
        reason: 'Selecting a place cannot move the GPS marker',
      );
      now = now.add(const Duration(seconds: 5));
      await emit(fix(now, longitude: 20.002));
      expect(navigation.progress, greaterThan(60));
      expect(
        navigation.route,
        isNot(same(firstRoute)),
        reason: 'Explicitly selecting the target replans once',
      );
      final activeRoute = navigation.route;
      now = now.add(const Duration(seconds: 5));
      await emit(fix(now, longitude: 20.003));
      expect(
        navigation.route,
        same(activeRoute),
        reason: 'On-path fixes preserve upcoming turn cues',
      );
      expect(location.position!.longitude, 20.003);
    },
  );

  test(
    'denied permission, approximate GPS and out-of-area GPS cannot guide',
    () async {
      source.allowed = LocationPermission.denied;
      await location.start();
      expect(source.requests, 1);
      expect(location.state, LocationState.denied);
      expect(location.position, isNull);
      source.allowed = LocationPermission.whileInUse;
      await location.start();
      navigation.navigateTo(target);
      await emit(fix(now, accuracy: 100));
      expect(location.position, isNotNull);
      expect(navigation.route, isNull);
      expect(location.isPrecise, isFalse);
      await emit(fix(now, longitude: 21));
      expect(navigation.outsideMap, isTrue);
      expect(navigation.route, isNull);
      expect(
        location.position!.longitude,
        21,
        reason: 'Never clamp an out-of-map fix into the demo area',
      );
    },
  );

  test(
    'stale fixes, service errors and pause remove marker and directions',
    () async {
      await location.start();
      navigation.navigateTo(target);
      await emit(fix(now));
      now = now.add(const Duration(seconds: 31));
      location.checkFreshness();
      expect(location.state, LocationState.stale);
      expect(location.position, isNull);
      expect(navigation.route, isNull);
      await emit(fix(now.subtract(const Duration(seconds: 40))));
      expect(location.position, isNull);
      await emit(fix(now));
      expect(navigation.route, isNotNull);
      location.pause();
      expect(location.position, isNull);
      expect(navigation.route, isNull);
      await emit(fix(now));
      expect(location.position, isNull);
      await location.resume();
      await emit(fix(now));
      source.updates.addError(const LocationServiceDisabledException());
      await Future<void>.delayed(Duration.zero);
      expect(location.state, LocationState.disabled);
      expect(location.position, isNull);
      expect(navigation.route, isNull);
    },
  );

  test(
    'cancelled calculations cannot restore a route or destination',
    () async {
      await location.start();
      await emit(fix(now));
      navigation.navigateTo(target);
      expect(navigation.isCalculating, isTrue);
      navigation.stop();
      expect(navigation.isCalculating, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(navigation.destination, isNull);
      expect(navigation.route, isNull);
      navigation.navigateTo(target);
      expect(navigation.isCalculating, isTrue);
      location.pause();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(navigation.isCalculating, isFalse);
      expect(navigation.route, isNull);
    },
  );

  test('fictional photos never create a walking destination', () async {
    navigation.navigateTo(
      const Landmark(
        id: '2_2',
        name: 'Demo',
        photoName: '2_2.photo',
        latitude: 50.015,
        longitude: 20.018,
        isDemo: true,
      ),
    );
    expect(navigation.destination, isNull);
    expect(navigation.route, isNull);
  });

  test('turn-by-turn cues follow the directed path and keep road names', () {
    final map = roadMap();
    final path = OfflineRouter(map).routeDetails(
      map.project([20.001, 50.005]),
      map.project([20.018, 50.015]),
    )!;
    final route = WalkingRoute(map, path);
    expect(route.turns.map((turn) => turn.action), [
      'skręć w lewo — Park path',
      'skręć w prawo — Park path',
    ]);
    expect(
      route.instructionAt(route.turns.first.distance - 8),
      'Skręć w lewo — Park path.',
    );
    expect(
      route.instructionAt(route.turns.last.distance + 20),
      contains('na wschód'),
    );
    final reverse = WalkingRoute(
      map,
      OfflineRouter(map).routeDetails(
        map.project([20.018, 50.015]),
        map.project([20.001, 50.005]),
      )!,
    );
    expect(reverse.turns.map((turn) => turn.action), [
      'skręć w lewo — Park path',
      'skręć w prawo — Park path',
    ]);
  });

  test(
    'reaching the snapped path endpoint is not arrival at an offset photo pin',
    () async {
      const offset = Landmark(
        id: '3_3',
        name: 'Off-path photo',
        photoName: '3_3.photo',
        latitude: 50.0154,
        longitude: 20.018,
      );
      await location.start();
      navigation.navigateTo(offset);
      await emit(fix(now));
      expect(navigation.route, isNotNull);
      await emit(fix(now, latitude: 50.015, longitude: 20.018));
      expect(navigation.remaining, lessThan(1));
      expect(navigation.nearPlace, isFalse);
      expect(navigation.instruction, contains('ścieżka kończy się'));
    },
  );

  test(
    'unconnected destinations have no straight-line walking fallback',
    () async {
      navigation.navigateTo(
        const Landmark(
          id: '4_4',
          name: 'Far pin',
          photoName: '4_4.photo',
          latitude: 50.019,
          longitude: 20.019,
        ),
      );
      await location.start();
      await emit(fix(now));
      expect(navigation.route, isNull);
      expect(navigation.instruction, contains('Brak połączonej trasy pieszej'));
    },
  );
}
