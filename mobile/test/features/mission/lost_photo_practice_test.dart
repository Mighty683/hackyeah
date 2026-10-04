import 'dart:convert';
import 'dart:io';

import 'package:do_bazy/features/landmarks/data/landmark.dart';
import 'package:do_bazy/features/landmarks/data/landmark_repository.dart';
import 'package:do_bazy/features/landmarks/widgets/landmark_map.dart';
import 'package:do_bazy/features/landmarks/widgets/landmark_photo.dart';
import 'package:do_bazy/features/mission/data/lost_practice_context.dart';
import 'package:do_bazy/features/mission/lost_mission_launcher.dart';
import 'package:do_bazy/features/mission/lost_mission_scene.dart';
import 'package:do_bazy/features/mission/lost_meeting_point_map.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:do_bazy/features/parent/practice_meeting_point_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _target = Landmark(
  id: '1_1',
  name: 'Library entrance',
  photoName: '1_1.photo',
  latitude: 50.0675,
  longitude: 19.991,
  icon: '📚',
);
// Duplicate names must never identify the correct place.
const _other = Landmark(
  id: '2_2',
  isDemo: true,
  name: 'Library entrance',
  photoName: '2_2.photo',
  latitude: 50.0705,
  longitude: 19.995,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late _PhotoRepository photos;
  const audio = MethodChannel('basebound/mission_audio');
  final audioCalls = <MethodCall>[];
  setUp(() async {
    audioCalls.clear();
    rootBundle.clear();
    FlutterSecureStorage.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('lost-photo-practice-');
    final image = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aOioAAAAASUVORK5CYII=',
    );
    for (final place in [_target, _other]) {
      await File('${directory.path}/${place.photoName}').writeAsBytes(image);
    }
    photos = _PhotoRepository(directory, [_target, _other]);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audio, (call) async {
          audioCalls.add(call);
          return call.method == 'initialize' ? true : null;
        });
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audio, null);
    await directory.delete(recursive: true);
  });

  testWidgets(
    'parent-selected photo leads to ID-based recognition and Our map',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final family = FamilyPlanRepository();
      await family.save(
        const FamilyPlan(
          contacts: [TrustedContact(name: 'Parent')],
          safePoints: [
            SafePoint(
              name: 'Dom',
              latitude: 50.0704,
              longitude: 19.9828,
              isDemo: true,
            ),
          ],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PracticeMeetingPointEditorScreen(
                      repository: photos,
                      onSave: (point) async => family.save(
                        (await family.load()).copyWith(
                          practiceMeetingPoint: point,
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('Choose meeting place'),
              ),
            ),
          ),
        ),
      );
      await _tap(tester, find.text('Choose meeting place'));
      await _pump(tester);
      await _tap(tester, find.byKey(const ValueKey('meeting-place-1_1')));
      await _tap(tester, find.text('Zapisz punkt spotkania do ćwiczeń'));
      final saved = await family.load();
      expect(saved.practiceMeetingPoint!.landmarkId, _target.id);
      expect(saved.contacts.single.name, 'Parent');
      expect(saved.safePoints.single.name, 'Dom');

      await tester.pumpWidget(
        MaterialApp(
          home: LostMissionLauncher(
            repository: family,
            landmarkRepository: photos,
          ),
        ),
      );
      await _pump(tester);
      expect(
        tester.widget<LandmarkPhoto>(find.byType(LandmarkPhoto)).path,
        '${directory.path}/1_1.photo',
      );
      expect(find.text('Demo meeting place.'), findsNothing);
      await _tap(tester, find.text('Punkt spotkania w pobliżu'));
      await _tap(tester, find.byKey(const ValueKey('lost-choice-stop')));
      await _finishFeedback(tester);
      expect(
        tester.widget<LandmarkPhoto>(find.byType(LandmarkPhoto)).path,
        '${directory.path}/1_1.photo',
      );
      await _next(tester);
      expect(find.text('Fictional demo photo'), findsNothing);
      await _tap(tester, find.byKey(const ValueKey('lost-choice-2_2')));
      expect(find.textContaining('To inne miejsce.'), findsOneWidget);
      expect(find.byKey(const ValueKey('lost-primary-action')), findsNothing);
      await _tap(tester, find.byKey(const ValueKey('lost-choice-1_1')));
      await _finishFeedback(tester);
      await _pump(tester);
      expect(find.byType(LostMeetingPointMap), findsOneWidget);
      final map = tester.widget<LandmarkMap>(find.byType(LandmarkMap));
      expect(map.position, isNull);
      expect(map.route, isEmpty);
      expect(map.selectedId, isNull);
      final home = map.landmarks.singleWhere(
        (place) => place.id == LostPracticeHomePoint.id,
      );
      expect(home.name, 'Dom');
      expect(home.isDestination, isTrue);
      expect(home.photoAsset, 'assets/landmarks/demo-home.png');
      expect(home.photoName, isEmpty);
      expect(home.latitude, saved.safePoints.single.latitude);
      expect(home.longitude, saved.safePoints.single.longitude);
      expect(find.byKey(const ValueKey('live-gps-marker')), findsNothing);
      expect(find.text('Idźcie tutaj razem'), findsNothing);
      // Home is enabled as a map choice; the agreed photo remains the target.
      await _tap(tester, find.text('Miejsca'));
      expect(find.text('Fictional demo place'), findsNothing);
      await _tap(tester, find.text('Dom'));
      expect(find.textContaining('Dom to inne miejsce.'), findsOneWidget);
      expect(find.byType(LostMeetingPointMap), findsOneWidget);
      const homeFeedback =
          'Dom to inne miejsce. Poszukaj zdjęcia miejsca spotkania.';
      int homeNarrationCount() => audioCalls
          .where(
            (call) =>
                call.method == 'narrate' &&
                (call.arguments as Map)['text'] == homeFeedback,
          )
          .length;
      final firstHomeNarrationCount = homeNarrationCount();
      expect(firstHomeNarrationCount, greaterThan(0));
      await _tap(tester, find.text('Miejsca'));
      await _tap(tester, find.text('Dom'));
      expect(find.text(homeFeedback), findsOneWidget);
      expect(homeNarrationCount(), firstHomeNarrationCount + 1);
      expect((await family.load()).toJson(), saved.toJson());
      // Another map pin remains available immediately after retry feedback.
      map.onSelected(_other);
      await _pump(tester);
      expect(
        find.textContaining('Ten znacznik wskazuje inne miejsce.'),
        findsOneWidget,
      );
      await _tap(tester, find.text('Miejsca'));
      await _tap(tester, find.text('Library entrance').first);
      await _pump(tester);
      // The list retains stored order: the first record is the target.
      expect(find.textContaining('Jeszcze tam nie jesteś.'), findsOneWidget);
      await _finishFeedback(tester);
      expect(_step(tester), 'arrive');
      expect(
        tester.widget<LandmarkPhoto>(find.byType(LandmarkPhoto)).path,
        '${directory.path}/1_1.photo',
      );
      expect(find.textContaining('W tej historii docierasz'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await _pump(tester);
    },
  );

  testWidgets('re-entry reloads a renamed linked landmark', (tester) async {
    final family = FamilyPlanRepository();
    await family.save(
      const FamilyPlan(
        practiceMeetingPoint: PracticeMeetingPoint(
          landmarkId: '1_1',
          label: 'Old name',
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: LostMissionLauncher(
          repository: family,
          landmarkRepository: photos,
        ),
      ),
    );
    await _pump(tester);
    expect(
      find.text('Punkt spotkania na niby: Library entrance'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await _pump(tester);
    photos.places = [
      const Landmark(
        id: '1_1',
        name: 'Main library door',
        photoName: '1_1.photo',
        latitude: 50.0675,
        longitude: 19.991,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: LostMissionLauncher(
          repository: family,
          landmarkRepository: photos,
        ),
      ),
    );
    await _pump(tester);
    expect(
      find.text('Punkt spotkania na niby: Main library door'),
      findsOneWidget,
    );
    expect((await family.load()).practiceMeetingPoint!.label, 'Old name');
    await tester.pumpWidget(const SizedBox.shrink());
    await _pump(tester);
  });

  for (final missingPhoto in [true, false]) {
    testWidgets(
      'missing ${missingPhoto ? 'photo' : 'landmark'} requires setup without substituting another place',
      (tester) async {
        final family = FamilyPlanRepository();
        await family.save(
          const FamilyPlan(
            practiceMeetingPoint: PracticeMeetingPoint(
              landmarkId: '1_1',
              label: 'Library entrance',
            ),
          ),
        );
        final before = (await family.load()).toJson();
        if (missingPhoto) {
          await tester.runAsync(
            () => File('${directory.path}/1_1.photo').delete(),
          );
        } else {
          photos.places = [_other];
        }
        await tester.pumpWidget(
          MaterialApp(
            home: LostMissionLauncher(
              repository: family,
              landmarkRepository: photos,
            ),
          ),
        );
        await _pump(tester);
        expect(
          find.text('Miejsce spotkania lub zdjęcie jest niedostępne.'),
          findsOneWidget,
          reason: _texts(tester),
        );
        expect(find.text('Punkt spotkania w pobliżu'), findsNothing);
        expect(find.byType(LandmarkPhoto), findsNothing);
        expect(find.text('Use demo meeting place'), findsNothing);
        expect(find.text('Ustawienia rodziny'), findsOneWidget);
        expect((await family.load()).toJson(), before);
        await tester.pumpWidget(const SizedBox.shrink());
        await _pump(tester);
      },
    );
  }

  testWidgets(
    'saved photo lets an unconfigured install start without a setup gate',
    (tester) async {
      final family = FamilyPlanRepository();
      final before = (await family.load()).toJson();
      await tester.pumpWidget(
        MaterialApp(
          home: LostMissionLauncher(
            repository: family,
            landmarkRepository: photos,
          ),
        ),
      );
      await _pump(tester);
      expect(
        find.text('Punkt spotkania na niby: Library entrance'),
        findsOneWidget,
      );
      expect(find.text('Punkt spotkania w pobliżu'), findsOneWidget);
      expect(find.text('Use demo meeting place'), findsNothing);
      expect((await family.load()).toJson(), before);
      await tester.pumpWidget(const SizedBox.shrink());
      await _pump(tester);
    },
  );
}

class _PhotoRepository extends LandmarkRepository {
  _PhotoRepository(this.directory, this.places);
  final Directory directory;
  List<Landmark> places;
  @override
  Future<List<Landmark>> load() async => places;
  @override
  Future<Directory> photoDirectory() async => directory;
}

String _step(WidgetTester tester) =>
    tester.widget<LostMissionScene>(find.byType(LostMissionScene)).step.id;
Future<void> _next(WidgetTester tester) =>
    _tap(tester, find.byKey(const ValueKey('lost-primary-action')));
Future<void> _finishFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await _pump(tester);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await _pump(tester);
}

Future<void> _pump(WidgetTester tester) async {
  // Asset loading, image decoding and file checks cross the fake-async boundary.
  for (var frame = 0; frame < 100; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    if (frame >= 7 &&
        find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      return;
    }
  }
  fail('Loading did not finish: ${_texts(tester)}');
}

String _texts(WidgetTester tester) => find
    .byType(Text)
    .evaluate()
    .map((element) => (element.widget as Text).data)
    .join(" | ");
