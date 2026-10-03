import 'package:flutter_test/flutter_test.dart';

import 'package:do_bazy/game/maps/demo_map.dart';
import 'package:do_bazy/game/maps/offline_router.dart';

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

  test('bundled map connects two real geographic points offline', () async {
    final map = await DemoMapRepository().load();
    final router = OfflineRouter(map);
    final route = router.route(
      map.project(map.center),
      map.project([20.0013, 50.0730]),
    );
    expect(
      route,
      isNotNull,
      reason: 'The bundled pedestrian network must remain connected',
    );
    expect(route!.length, greaterThan(2));
  });
}
