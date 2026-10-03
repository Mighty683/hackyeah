import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:do_bazy/game/components/player_component.dart';
import 'package:do_bazy/game/components/practice_route_component.dart';
import 'package:do_bazy/game/maps/demo_map.dart';
import 'package:do_bazy/game/maps/offline_router.dart';
import 'package:do_bazy/game/neighborhood_game.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';

DemoMap fixture(List<DemoMapFeature> features) =>
    DemoMap(bounds: [0, 0, 396, 396], center: [0, 0], features: features);

DemoMapFeature line(
  String id,
  List<List<num>> coordinates, {
  Map<String, dynamic> tags = const {},
}) => DemoMapFeature(
  id: id,
  properties: {'layer': 'road', 'highway': 'footway', ...tags},
  geometryType: 'LineString',
  coordinates: coordinates,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A* chooses a shorter connected detour, never a straight shortcut', () {
    final map = fixture([
      line('long', [
        [0, 0],
        [0, 40],
        [40, 40],
        [40, 0],
      ]),
      line('short', [
        [0, 0],
        [0, 20],
        [40, 20],
        [40, 0],
      ]),
    ]);
    final route = OfflineRouter(map)
        .route(map.project([0, 0]), map.project([40, 0]))!;
    var length = 0.0;
    for (var i = 1; i < route.length; i++) {
      length += route[i - 1].distanceTo(route[i]);
    }
    expect(length, closeTo(80, .001));
    expect(route.any((p) => p.distanceTo(map.project([0, 20])) < .001), isTrue);
  });

  test('crossing lines without a shared source vertex remain disconnected', () {
    final map = fixture([
      line('a', [
        [0, 20],
        [40, 20],
      ]),
      line('b', [
        [20, 0],
        [20, 40],
      ]),
    ]);
    expect(
      OfflineRouter(map).route(map.project([0, 20]), map.project([20, 40])),
      isNull,
    );
  });

  test(
    'private and foot=no links cannot complete a route; distant pins fail',
    () {
      for (final tags in [
        {'access': 'private'},
        {'foot': 'no'},
      ]) {
        final map = fixture([
          line('a', [
            [0, 0],
            [20, 0],
          ]),
          line('restricted', [
            [20, 0],
            [40, 0],
          ], tags: tags),
          line('b', [
            [40, 0],
            [60, 0],
          ]),
        ]);
        final router = OfflineRouter(map);
        expect(router.route(map.project([0, 0]), map.project([60, 0])), isNull);
        expect(
          router.route(map.project([0, 0]), map.project([200, 200])),
          isNull,
        );
      }
    },
  );

  test(
    'pedestrian preference accepts a small detour but permits a shorter road',
    () {
      for (final detourHeight in [5, 40]) {
        final map = fixture([
          line(
            'road',
            [
              [0, 0],
              [40, 0],
            ],
            tags: {'highway': 'residential'},
          ),
          line('footpath', [
            [0, 0],
            [0, detourHeight],
            [40, detourHeight],
            [40, 0],
          ]),
        ]);
        final route = OfflineRouter(map)
            .route(map.project([0, 0]), map.project([40, 0]))!;
        final usesDetour = route.any(
          (p) => p.distanceTo(map.project([0, detourHeight])) < .001,
        );
        expect(usesDetour, detourHeight == 5);
      }
    },
  );

  test('sidepath and limited access restrictions cannot become shortcuts', () {
    for (final tags in [
      {'foot': 'use_sidepath'},
      {'foot': 'customers'},
      {'access': 'customers'},
      {'access': 'destination'},
      {'access': 'delivery'},
      {'hazard': 'landslide'},
      {'foot:conditional': 'yes @ (sunrise-sunset)'},
    ]) {
      final map = fixture([
        line('restricted', [
          [0, 0],
          [40, 0],
        ], tags: tags),
        line('detour', [
          [0, 0],
          [0, 20],
          [40, 20],
          [40, 0],
        ]),
      ]);
      final route = OfflineRouter(map)
          .route(map.project([0, 0]), map.project([40, 0]))!;
      expect(
        route.any((p) => p.distanceTo(map.project([0, 20])) < .001),
        isTrue,
        reason: '$tags',
      );
    }
  });

  test('explicit foot permission overrides general access but not foot restrictions', () {
    final map = fixture([
      line(
        'public-foot',
        [
          [0, 0],
          [40, 0],
        ],
        tags: {'access': 'private', 'foot': 'yes'},
      ),
    ]);
    expect(
      OfflineRouter(map).route(map.project([0, 0]), map.project([40, 0])),
      isNotNull,
    );
  });

  test(
    'blockage prevents intersecting edges and never falls back through it',
    () {
      final direct = line('direct', [
        [0, 0],
        [60, 0],
      ]);
      final detour = line('detour', [
        [0, 0],
        [0, 20],
        [60, 20],
        [60, 0],
      ]);
      final map = fixture([direct, detour]);
      final blockage = PracticeBlockage(
        center: map.project([30, 0]),
        radius: 3,
      );
      final route = OfflineRouter(
        map,
        blockage: blockage,
      ).route(map.project([0, 0]), map.project([60, 0]))!;
      for (var i = 1; i < route.length; i++) {
        expect(blockage.intersects(route[i - 1], route[i]), isFalse);
      }
      expect(
        OfflineRouter(
          fixture([direct]),
          blockage: blockage,
        ).route(map.project([0, 0]), map.project([60, 0])),
        isNull,
      );
      expect(
        OfflineRouter(
          map,
          blockage: blockage,
        ).route(map.project([0, 0]), map.project([30, 0])),
        isNull,
      );
    },
  );

  test('walking one-way restrictions are applied in the source direction', () {
    for (final direction in ['yes', '-1']) {
      final map = fixture([
        line(
          'one-way',
          [
            [0, 0],
            [40, 0],
          ],
          tags: {'oneway:foot': direction},
        ),
      ]);
      final router = OfflineRouter(map);
      expect(
        router.route(map.project([0, 0]), map.project([40, 0])) != null,
        direction == 'yes',
      );
      expect(
        router.route(map.project([40, 0]), map.project([0, 0])) != null,
        direction == '-1',
      );
    }
  });

  test('movement consumes waypoints around bends and resets cleanly', () {
    final player = PlayerComponent(startPosition: Vector2.zero());
    player.followPath([Vector2.zero(), Vector2(30, 0), Vector2(30, 30)]);
    player.update(1.5);
    expect(player.position.x, 30);
    expect(player.position.y, 15);
    expect(player.isMoving, isTrue);
    player.update(10);
    expect(player.position, Vector2(30, 30));
    expect(player.isMoving, isFalse);
    player.reset(Vector2.zero());
    expect(player.position, Vector2.zero());
  });

  test('bundled map routes the demo journey offline', () async {
    final map = await DemoMapRepository().load();
    final router = OfflineRouter(map);
    final route = router.route(
      map.project(map.center),
      map.project([20.0013, 50.0730]),
    );
    expect(
      route,
      isNotNull,
      reason: 'The fictional base must remain reachable for the demo',
    );
    expect(route!.length, greaterThan(2));
  });

  testWidgets(
    'game follow action arrives once and restart restores the route',
    (tester) async {
      var arrivals = 0;
      final game = NeighborhoodGame(
        onArrived: () => arrivals++,
        gender: ChildGender.boy,
      );
      await tester.runAsync(() async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 396,
              height: 396,
              child: GameWidget(game: game),
            ),
          ),
        );
        await game.toBeLoaded();
        await game.ready();
      });
      game.pauseEngine();
      game.update(0);
      expect(game.hasRoute, isTrue);
      final guide = game.world.children
          .whereType<PracticeRouteComponent>()
          .single;
      final player = game.world.children.whereType<PlayerComponent>().single;
      expect(player.gender, ChildGender.boy);
      game.togglePracticeBlockage();
      expect(game.hasPracticeBlockage, isTrue);
      expect(
        game.hasRoute,
        isTrue,
        reason: 'The default demo should show an alternate route',
      );
      final blockage = guide.blockage!()!;
      final alternative = guide.points();
      for (var i = 1; i < alternative.length; i++) {
        expect(
          blockage.intersects(alternative[i - 1], alternative[i]),
          isFalse,
        );
      }
      game.togglePracticeBlockage();
      expect(game.hasPracticeBlockage, isFalse);
      expect(game.hasRoute, isTrue);
      game.showNearby();
      game.update(0);
      final nearby = guide.points()[2];
      final tap = game.camera.localToGlobal(nearby);
      game.selectDestination(tap.toOffset());
      expect(player.isMoving, isTrue);
      for (var i = 0; i < 20; i++) {
        game.update(.1);
      }
      expect(player.position.distanceTo(nearby), lessThan(.01));
      expect(arrivals, 0);
      expect(game.hasRoute, isTrue);
      game.followPracticePath();
      for (var i = 0; i < 1000; i++) {
        game.update(.1);
      }
      expect(arrivals, 1);
      game.restart();
      game.togglePracticeBlockage();
      game.restart();
      expect(game.hasPracticeBlockage, isFalse);
      expect(game.hasRoute, isTrue);
      game.followPracticePath();
      for (var i = 0; i < 1000; i++) {
        game.update(.1);
      }
      expect(arrivals, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
