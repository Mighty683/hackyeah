import 'dart:async';

import 'package:do_bazy/features/help/help_context.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import '../game/fake_location_source.dart';

void main() {
  late DateTime now;
  late FakeLocationSource source;
  late HelpContext context;

  const home = SafePoint(name: ' Home ', latitude: 50.005, longitude: 20.001);

  setUp(() {
    now = DateTime.utc(2026, 10, 3, 12);
    source = FakeLocationSource();
    context = HelpContext(
      source: source,
      now: () => now,
      loadPlan: () async => const FamilyPlan(safePoints: [home]),
    );
  });

  tearDown(() async {
    context.dispose();
    await source.updates.close();
  });

  Future<void> emit(Position position) async {
    source.updates.add(position);
    await Future<void>.delayed(Duration.zero);
  }

  test('only named real saved places can become a nearby hint', () async {
    context.dispose();
    context = HelpContext(
      source: source,
      now: () => now,
      loadPlan: () async => const FamilyPlan(
        safePoints: [
          SafePoint(
            name: 'Fictional home',
            latitude: 50.005,
            longitude: 20.001,
            isDemo: true,
          ),
          SafePoint(name: ' ', latitude: 50.005, longitude: 20.001),
          SafePoint(
            name: 'Further place',
            latitude: 50.0052,
            longitude: 20.001,
          ),
          home,
        ],
      ),
    );
    await context.start();
    expect(context.nearbyPlaceName, isNull);
    await emit(fix(now));
    expect(context.nearbyPlaceName, 'Home');
    expect(source.requests, 0);
  });

  test(
    'nearby radius includes uncertainty and rejects approximate GPS',
    () async {
      await context.start();
      await emit(fix(now, latitude: 50.0053, accuracy: 20));
      expect(context.nearbyPlaceName, isNull);
      await emit(fix(now, latitude: 50.0053, accuracy: 5));
      expect(context.nearbyPlaceName, 'Home');
      await emit(fix(now, accuracy: 26));
      expect(context.nearbyPlaceName, isNull);
      await emit(fix(now, latitude: 50.006));
      expect(context.nearbyPlaceName, isNull);
    },
  );

  test('stale position is rejected before the freshness timer ticks', () async {
    await context.start();
    await emit(fix(now));
    expect(context.nearbyPlaceName, 'Home');
    now = now.add(const Duration(seconds: 31));
    expect(context.nearbyPlaceName, isNull);
    await emit(fix(now));
    expect(context.nearbyPlaceName, 'Home');
  });

  test(
    'denial and disabled location silently preserve help without prompts',
    () async {
      source.allowed = LocationPermission.denied;
      await context.start();
      expect(context.nearbyPlaceName, isNull);
      expect(source.requests, 0);
      expect(source.updates.hasListener, isFalse);
      source.allowed = LocationPermission.whileInUse;
      source.enabled = false;
      await context.resume();
      expect(context.nearbyPlaceName, isNull);
      expect(source.requests, 0);
      expect(source.updates.hasListener, isFalse);
    },
  );

  test(
    'pause cancels tracking and resume requires a new received fix',
    () async {
      await context.start();
      await emit(fix(now));
      expect(context.nearbyPlaceName, 'Home');
      context.pause();
      expect(source.updates.hasListener, isFalse);
      expect(context.nearbyPlaceName, isNull);
      await emit(fix(now));
      expect(context.nearbyPlaceName, isNull);
      await context.resume();
      expect(source.updates.hasListener, isTrue);
      expect(context.nearbyPlaceName, isNull);
      await emit(fix(now));
      expect(context.nearbyPlaceName, 'Home');
      expect(source.requests, 0);
    },
  );

  test('unreadable family data leaves nearby context absent', () async {
    context.dispose();
    context = HelpContext(
      source: source,
      now: () => now,
      loadPlan: () async => throw const FormatException('Unavailable plan'),
    );
    await context.start();
    await emit(fix(now));
    expect(context.nearbyPlaceName, isNull);
  });

  test('late family load cannot notify after disposal', () async {
    context.dispose();
    final plan = Completer<FamilyPlan>();
    final pendingContext = HelpContext(
      source: source,
      now: () => now,
      loadPlan: () => plan.future,
    );
    final start = pendingContext.start();
    await Future<void>.delayed(Duration.zero);
    pendingContext.dispose();
    expect(source.updates.hasListener, isFalse);
    plan.complete(const FamilyPlan(safePoints: [home]));
    await start;
    // Give the shared teardown a live, unstarted instance to dispose.
    context = HelpContext(
      source: source,
      loadPlan: () async => const FamilyPlan(),
    );
  });
}
