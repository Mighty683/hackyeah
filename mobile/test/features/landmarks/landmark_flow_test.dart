import 'dart:convert';
import 'dart:io';

import 'package:do_bazy/features/landmarks/data/landmark.dart';
import 'package:do_bazy/features/landmarks/landmark_editor_screen.dart';
import 'package:do_bazy/features/game/game_screen.dart';
import 'package:do_bazy/features/game/navigation_location.dart';

import '../game/fake_location_source.dart';

import 'package:do_bazy/game/maps/demo_map.dart';
import 'package:do_bazy/features/landmarks/widgets/landmark_map.dart';
import 'package:do_bazy/features/landmarks/widgets/landmark_photo.dart';
import 'package:do_bazy/ui/basebound_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('basebound-photo-smoke-');
    final image = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aOioAAAAASUVORK5CYII=',
    );
    for (final name in ['source.photo', '1_1.photo', '2_2.photo']) {
      await File('${directory.path}/$name').writeAsBytes(image);
    }
  });
  tearDown(() async => directory.delete(recursive: true));

  testWidgets('parent saves a named photo point after manual map placement', (
    tester,
  ) async {
    Landmark? saved;
    await _start(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LandmarkEditorScreen(
                  photoPath: '${directory.path}/source.photo',
                  otherPoints: const [],
                  onSave: (entry) async => saved = entry,
                ),
              ),
            ),
            child: const Text('Open landmark'),
          ),
        ),
      ),
    );
    await _tap(tester, 'Open landmark');
    await tester.enterText(find.byType(TextField), 'Red corner shop');
    await _tap(tester, 'Choose map position', settle: false);
    await _pumpMap(tester);
    expect(_saveButton(tester).onPressed, isNull);
    await _tap(tester, 'Use arena centre', settle: false);
    await _pumpMap(tester);
    expect(_saveButton(tester).onPressed, isNotNull);
    await _tap(tester, 'Save landmark', settle: false);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(saved?.name, 'Red corner shop');
    expect(saved?.latitude, inInclusiveRange(50, 51));
    expect(saved?.longitude, inInclusiveRange(19, 21));
    expect(find.byType(LandmarkEditorScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('map taps open photos without moving the live GPS position', (
    tester,
  ) async {
    final geography = DemoMap.fromJson(
      jsonDecode(File('assets/maps/tauron-arena.geojson').readAsStringSync())
          as Map<String, dynamic>,
    );
    final now = DateTime.utc(2026, 10, 3, 12);
    final source = FakeLocationSource();
    final location = NavigationLocation(source: source, now: () => now);
    final landmark = Landmark(
      id: '1_1',
      name: 'Photo shop',
      photoName: '1_1.photo',
      latitude: geography.center[1].toDouble() + .003,
      longitude: geography.center[0].toDouble() + .003,
    );
    await _start(
      tester,
      GameScreen(
        map: geography,
        landmarks: [landmark],
        photoDirectory: directory.path,
        location: location,
      ),
      settle: false,
    );
    await _pumpMap(tester);
    expect(find.byKey(const ValueKey('live-gps-marker')), findsNothing);
    await tester.tap(find.byTooltip('Photo shop'));
    await tester.pump();
    expect(find.text('Walk here together'), findsOneWidget);
    expect(location.position, isNull);
    expect(location.isTracking, isTrue);
    expect(source.requests, 0);
    final camera = tester
        .widget<InteractiveViewer>(find.byType(InteractiveViewer))
        .transformationController!;
    expect(camera.value.getMaxScaleOnAxis(), 1);
    final initialCamera = camera.value.clone();
    source.updates.add(
      fix(
        now,
        latitude: geography.center[1].toDouble(),
        longitude: geography.center[0].toDouble(),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('live-gps-marker')), findsOneWidget);
    expect(camera.value, initialCamera, reason: 'GPS must not move the camera');
    final mapBounds = tester.getRect(find.byType(InteractiveViewer));
    final centre =
        mapBounds.topLeft + Offset(mapBounds.width / 2, mapBounds.height / 4);
    final left = await tester.startGesture(
      centre - const Offset(30, 0),
      pointer: 1,
    );
    final right = await tester.startGesture(
      centre + const Offset(30, 0),
      pointer: 2,
    );
    await tester.pump();
    await left.moveTo(centre - const Offset(70, 0));
    await right.moveTo(centre + const Offset(70, 0));
    await tester.pump();
    await left.up();
    await right.up();
    await tester.pump();
    expect(camera.value.getMaxScaleOnAxis(), greaterThan(1));
    final gestureCamera = camera.value.clone();
    source.updates.add(
      fix(
        now,
        latitude: geography.center[1].toDouble() + .0001,
        longitude: geography.center[0].toDouble(),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(
      camera.value,
      gestureCamera,
      reason: 'GPS must preserve the gesture camera',
    );
    final received = location.position;
    await tester.tapAt(tester.getCenter(find.byType(LandmarkMap)));
    await tester.pump(const Duration(seconds: 2));
    expect(location.position, same(received));
    expect(
      tester.widget<LandmarkMap>(find.byType(LandmarkMap)).position,
      same(received),
    );
    expect(find.text('Follow path'), findsNothing);
    expect(find.text('Block a path'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    location.dispose();
    await source.updates.close();
    expect(tester.takeException(), isNull);
  });

  testWidgets('denied GPS keeps gesture map and accessible places available', (
    tester,
  ) async {
    final geography = DemoMap.fromJson(
      jsonDecode(File('assets/maps/tauron-arena.geojson').readAsStringSync())
          as Map<String, dynamic>,
    );
    final source = FakeLocationSource()..allowed = LocationPermission.denied;
    final location = NavigationLocation(source: source);
    final landmark = Landmark(
      id: '1_1',
      name: 'Photo shop',
      photoName: '1_1.photo',
      latitude: geography.center[1].toDouble(),
      longitude: geography.center[0].toDouble(),
    );
    await _start(
      tester,
      GameScreen(
        map: geography,
        landmarks: [landmark],
        photoDirectory: directory.path,
        location: location,
      ),
      settle: false,
    );
    await _pumpMap(tester);
    expect(source.requests, 0);
    expect(location.state, LocationState.denied);
    expect(
      find.text('Location is not allowed. You can still explore.'),
      findsOneWidget,
    );
    expect(find.text('Use live GPS'), findsNothing);
    expect(find.text('Stop GPS'), findsNothing);
    for (final tooltip in [
      'Zoom in',
      'Zoom out',
      'Show whole map',
      'Show me',
    ]) {
      expect(find.byTooltip(tooltip), findsNothing);
    }
    await _tap(tester, 'Places', settle: false);
    await _pumpTransition(tester);
    expect(tester.getRect(find.text('Photo shop')).bottom, lessThan(844));
    await _tap(tester, 'Photo shop', settle: false);
    await _pumpTransition(tester);
    expect(find.text('Walk here together'), findsOneWidget);
    expect(find.text('Our places'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    location.dispose();
    await source.updates.close();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help and background pause GPS until foreground map returns', (
    tester,
  ) async {
    const audioChannel = MethodChannel('basebound/mission_audio');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      audioChannel,
      (call) async => call.method == 'initialize' ? false : null,
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        audioChannel,
        null,
      );
    });
    final geography = DemoMap.fromJson(
      jsonDecode(File('assets/maps/tauron-arena.geojson').readAsStringSync())
          as Map<String, dynamic>,
    );
    final source = FakeLocationSource();
    final location = NavigationLocation(source: source);
    await _start(
      tester,
      GameScreen(
        map: geography,
        landmarks: const [],
        photoDirectory: directory.path,
        location: location,
      ),
      settle: false,
    );
    await _pumpMap(tester);
    expect(location.isTracking, isTrue);
    expect(source.requests, 0);

    await tester.tap(find.byTooltip('I need help · prototype'));
    await _pumpTransition(tester);
    expect(find.byTooltip('Close help'), findsOneWidget);
    expect(location.state, LocationState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(
      location.state,
      LocationState.paused,
      reason: 'Help keeps GPS paused',
    );

    await tester.tap(find.byTooltip('Close help'));
    await _pumpTransition(tester);
    expect(location.isTracking, isTrue);
    expect(source.requests, 0);

    await tester.tap(find.byTooltip('I need help · prototype'));
    await _pumpTransition(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.tap(find.byTooltip('Close help'));
    await _pumpTransition(tester);
    expect(
      location.state,
      LocationState.paused,
      reason: 'Closing Help in background cannot resume GPS',
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(location.isTracking, isTrue);
    expect(source.requests, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    location.dispose();
    await source.updates.close();
    expect(tester.takeException(), isNull);
  });

  testWidgets('child retries a wrong map pin and learns the correct location', (
    tester,
  ) async {
    final geography = DemoMap.fromJson(
      jsonDecode(File('assets/maps/tauron-arena.geojson').readAsStringSync())
          as Map<String, dynamic>,
    );
    final landmarks = [
      Landmark(
        id: '1_1',
        name: 'Red shop',
        photoName: '1_1.photo',
        latitude: geography.center[1].toDouble(),
        longitude: geography.center[0].toDouble(),
      ),
      Landmark(
        id: '2_2',
        name: 'Playground',
        photoName: '2_2.photo',
        latitude: geography.center[1].toDouble() + .003,
        longitude: geography.center[0].toDouble() + .003,
      ),
    ];
    await _start(
      tester,
      GameScreen(
        map: geography,
        landmarks: landmarks,
        photoDirectory: directory.path,
      ),
      settle: false,
    );
    await _pumpMap(tester);
    await _tap(tester, 'Find the photo pin', settle: false);
    final target = tester
        .widget<LandmarkPhoto>(find.byType(LandmarkPhoto))
        .label;
    final map = tester.widget<LandmarkMap>(find.byType(LandmarkMap));
    final wrong = map.landmarks.indexWhere((entry) => entry.name != target);
    final right = map.landmarks.indexWhere((entry) => entry.name == target);
    await _tap(tester, 'Pin ${wrong + 1}', settle: false);
    expect(
      find.text('Another place. Look at the photo again.'),
      findsOneWidget,
    );
    expect(find.text('Try another place'), findsNothing);
    await _tap(tester, 'Pin ${right + 1}', settle: false);
    expect(find.text('You remembered! This place is here.'), findsOneWidget);
    await _tap(tester, 'Try another place', settle: false);
    expect(
      tester.widget<LandmarkPhoto>(find.byType(LandmarkPhoto)).label,
      isNot(target),
    );
    expect(
      tester.widget<LandmarkMap>(find.byType(LandmarkMap)).hidePhotos,
      isTrue,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Future<void> _start(
  WidgetTester tester,
  Widget screen, {
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(theme: BaseboundTheme.training(), home: screen),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _tap(
  WidgetTester tester,
  String label, {
  bool settle = true,
}) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _pumpMap(WidgetTester tester) async {
  for (var frame = 0; frame < 5; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

FilledButton _saveButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.ancestor(
    of: find.text('Save landmark'),
    matching: find.byWidgetPredicate((widget) => widget is FilledButton),
  ),
);

Future<void> _pumpTransition(WidgetTester tester) async {
  // Start the route animation, then finish it without waiting on Flame frames.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}
