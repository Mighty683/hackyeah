import 'dart:async';

import 'package:do_bazy/features/game/location_permission_setup.dart';
import 'package:do_bazy/features/help/help_screen.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:do_bazy/features/parent/parent_screen.dart';
import 'package:do_bazy/features/welcome/welcome_screen.dart';
import 'package:do_bazy/ui/basebound_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'fake_location_source.dart';

class _PermissionSource extends FakeLocationSource {
  LocationPermission requestedResult = LocationPermission.denied;
  Completer<LocationPermission>? pendingRequest;
  Completer<LocationPermission>? pendingCheck;
  bool failCheck = false;
  int streams = 0;

  @override
  Future<LocationPermission> permission() async {
    if (failCheck) throw StateError('Platform unavailable');
    return pendingCheck == null ? allowed : await pendingCheck!.future;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    allowed = pendingRequest == null
        ? requestedResult
        : await pendingRequest!.future;
    return allowed;
  }

  @override
  Stream<Position> positions() {
    streams++;
    return super.positions();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _PermissionSource source;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    source = _PermissionSource();
  });
  tearDown(() => source.updates.close());

  test('granted permission never prompts or subscribes at startup', () async {
    final setup = LocationPermissionSetup(source: source);
    expect(await setup.ensureRequestedOnce(), LocationPermissionStatus.granted);
    expect(source.requests, 0);
    expect(source.streams, 0);
  });

  test(
    'denial prompts once across new instances and family deletion',
    () async {
      source.allowed = LocationPermission.denied;
      expect(
        await LocationPermissionSetup(source: source).ensureRequestedOnce(),
        LocationPermissionStatus.denied,
      );
      await FamilyPlanRepository().deleteAll();
      expect(
        await LocationPermissionSetup(source: source).ensureRequestedOnce(),
        LocationPermissionStatus.denied,
      );
      expect(source.requests, 1);
      expect(source.streams, 0);
    },
  );

  test('startup callers share one request; adult retry is explicit', () async {
    source.allowed = LocationPermission.denied;
    source.pendingRequest = Completer<LocationPermission>();
    final setup = LocationPermissionSetup(source: source);
    final first = setup.ensureRequestedOnce();
    final second = setup.ensureRequestedOnce();
    expect(identical(first, second), isTrue);
    source.pendingRequest!.complete(LocationPermission.denied);
    await first;
    expect(source.requests, 1);
    source.pendingRequest = null;
    source.requestedResult = LocationPermission.whileInUse;
    expect(await setup.requestFromAdult(), LocationPermissionStatus.granted);
    expect(source.requests, 2);
    expect(source.streams, 0);
  });

  test('permanent denial directs settings without another prompt', () async {
    source.allowed = LocationPermission.deniedForever;
    var settingsOpened = 0;
    final setup = LocationPermissionSetup(
      source: source,
      openSettings: () async {
        settingsOpened++;
        return true;
      },
    );
    expect(
      await setup.ensureRequestedOnce(),
      LocationPermissionStatus.settingsRequired,
    );
    expect(
      await setup.requestFromAdult(),
      LocationPermissionStatus.settingsRequired,
    );
    expect(source.requests, 0);
    expect(settingsOpened, 0);
    expect(await setup.openSettings(), isTrue);
    expect(settingsOpened, 1);
  });

  test('a hidden welcome can defer the platform request', () async {
    source.allowed = LocationPermission.denied;
    final visible = Completer<void>();
    final waitingForVisibility = Completer<void>();
    final pending = LocationPermissionSetup(source: source).ensureRequestedOnce(
      beforeRequest: () {
        if (!waitingForVisibility.isCompleted) waitingForVisibility.complete();
        return visible.future;
      },
    );
    await waitingForVisibility.future;
    expect(source.requests, 0);
    visible.complete();
    expect(await pending, LocationPermissionStatus.denied);
    expect(source.requests, 1);
  });

  testWidgets('welcome gates both roles, keeps Help, then accepts denial', (
    tester,
  ) async {
    source.allowed = LocationPermission.denied;
    source.pendingRequest = Completer<LocationPermission>();
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(
          locationPermission: LocationPermissionSetup(source: source),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final choices = tester.widgetList<BaseboundActionTile>(
      find.byType(BaseboundActionTile),
    );
    expect(choices, hasLength(2));
    expect(choices.every((choice) => choice.onPressed == null), isTrue);
    expect(
      tester.widget<HelpEntryButton>(find.byType(HelpEntryButton)).onPressed,
      isNotNull,
    );
    source.pendingRequest!.complete(LocationPermission.denied);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<BaseboundActionTile>(find.byType(BaseboundActionTile))
          .every((choice) => choice.onPressed != null),
      isTrue,
    );
    expect(find.textContaining('Zdjęcia i ćwiczenia działają'), findsOneWidget);
    expect(source.requests, 1);
    expect(source.streams, 0);
  });

  testWidgets('Help defers welcome prompt until it closes', (tester) async {
    source.allowed = LocationPermission.denied;
    source.pendingCheck = Completer<LocationPermission>();
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(
          locationPermission: LocationPermissionSetup(source: source),
        ),
      ),
    );
    final help = find.byType(HelpEntryButton);
    await tester.ensureVisible(help);
    await tester.tap(help);
    await tester.pumpAndSettle();
    source.pendingCheck!.complete(LocationPermission.denied);
    await tester.pumpAndSettle();
    expect(find.byType(HelpScreen), findsOneWidget);
    expect(source.requests, 0);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(source.requests, 1);
    expect(source.streams, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('platform failure leaves welcome roles available', (
    tester,
  ) async {
    source.failCheck = true;
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(
          locationPermission: LocationPermissionSetup(source: source),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<BaseboundActionTile>(find.byType(BaseboundActionTile))
          .every((choice) => choice.onPressed != null),
      isTrue,
    );
    expect(source.requests, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('parent retries only after explicit permission action', (
    tester,
  ) async {
    source.allowed = LocationPermission.denied;
    source.requestedResult = LocationPermission.whileInUse;
    await tester.pumpWidget(
      MaterialApp(
        home: ParentScreen(
          locationPermission: LocationPermissionSetup(source: source),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(source.requests, 0);
    await tester.tap(find.byTooltip('Opcje ustawień'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dostęp mapy do lokalizacji'));
    await tester.pumpAndSettle();
    expect(source.requests, 0);
    await tester.tap(find.text('Zezwól na lokalizację'));
    await tester.pumpAndSettle();
    expect(source.requests, 1);
    expect(find.textContaining('Lokalizacja jest dozwolona.'), findsOneWidget);
    expect(source.streams, 0);
    expect(tester.takeException(), isNull);
  });
}
