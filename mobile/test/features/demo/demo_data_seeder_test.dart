import 'dart:io';

import 'package:do_bazy/features/child/child_onboarding_screen.dart';
import 'package:do_bazy/features/demo/data/demo_data_seeder.dart';
import 'package:do_bazy/features/help/help_phone.dart';
import 'package:do_bazy/features/landmarks/data/demo_landmarks.dart';
import 'package:do_bazy/features/landmarks/data/landmark.dart';
import 'package:do_bazy/features/landmarks/data/landmark_repository.dart';
import 'package:do_bazy/features/landmarks/landmark_location.dart';
import 'package:do_bazy/features/mission/practice_launcher.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:do_bazy/game/maps/demo_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  late Directory directory;
  late FamilyPlanRepository family;
  late LandmarkRepository landmarks;

  DemoDataSeeder seeder({LandmarkRepository? repository}) => DemoDataSeeder(
    storage: storage,
    familyRepository: family,
    landmarkRepository: repository ?? landmarks,
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('safe-path-seed-test-');
    family = FamilyPlanRepository(storage: storage);
    landmarks = LandmarkRepository(
      storage: storage,
      supportDirectory: () async => directory,
    );
  });

  tearDown(() async => directory.delete(recursive: true));

  test(
    'fresh install fills the family plan and adds readable fictional photos',
    () async {
      await seeder().seed();
      final plan = await family.load();
      expect(plan.child.fullName, 'Alex Example (demo)');
      expect(plan.child.age, 9);
      expect(plan.child.address, isNotEmpty);
      expect(plan.child.supportNotes, isNotEmpty);
      expect(plan.child.gender, ChildGender.boy);
      expect(plan.contacts.length, FamilyPlan.maxContacts);
      for (final contact in plan.contacts) {
        expect(contact.name, contains('Demo'));
        expect(contact.relationship, isNotEmpty);
        expect(normalizeTrustedPhone(contact.phone), isNotNull);
      }
      expect(plan.contacts.map((contact) => contact.phone).toSet().length, 3);
      expect(plan.safePoints.map((point) => point.name), [
        'Home',
        'School (demo)',
        'Park (demo)',
      ]);
      final saved = await landmarks.load();
      expect(saved.length, 3);
      expect(plan.practiceMeetingPoint!.landmarkId, saved.first.id);
      expect(plan.practiceMeetingPoint!.label, saved.first.name);
      final map = await DemoMapRepository().load();
      for (final point in plan.safePoints) {
        expect(point.icon, isNotEmpty);
        expect(point.isDemo, isTrue);
        expect(mapContainsPoint(map, point), isTrue);
      }
      for (final landmark in saved) {
        expect(landmark.isDemo, isTrue);
        expect(mapContainsPoint(map, landmark.point), isTrue);
        final photo = File(
          '${(await landmarks.photoDirectory()).path}/${landmark.photoName}',
        );
        final bytes = await photo.readAsBytes();
        expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      }
      await seeder().seed();
      expect((await family.load()).toJson(), plan.toJson());
      expect((await landmarks.load()).length, 3);
    },
  );

  testWidgets('seeded child starts practice without entering any details', (
    tester,
  ) async {
    await tester.runAsync(() => seeder().seed());
    final original = await family.load();
    await tester.pumpWidget(
      MaterialApp(home: ChildOnboardingScreen(repository: family)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      original.child.age.toString(),
    );
    for (final action in [
      'Add my name',
      'Choose my character',
      'Start practice',
    ]) {
      final button = find.text(action);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }
    expect(find.byType(PracticeLauncher), findsOneWidget);
    expect((await family.load()).toJson(), original.toJson());
    expect(tester.takeException(), isNull);
  });

  test(
    'existing family details are preserved without adding demo data',
    () async {
      const plan = FamilyPlan(
        child: ChildProfile(fullName: 'Test child'),
        safePoints: [
          SafePoint(name: 'Family place', latitude: 50.07, longitude: 19.99),
        ],
      );
      await family.save(plan);
      await seeder().seed();
      expect((await family.load()).toJson(), plan.toJson());
      expect(await landmarks.load(), isEmpty);
    },
  );

  test('saved empty family record is not treated as a fresh install', () async {
    await family.save(const FamilyPlan());
    await seeder().seed();
    expect((await family.load()).safePoints, isEmpty);
    expect(await landmarks.load(), isEmpty);
  });

  test(
    'saved empty landmark record is not treated as a fresh install',
    () async {
      await storage.write(
        key: LandmarkRepository.storageKey,
        value: '{"version":1,"landmarks":[]}',
      );
      await seeder().seed();
      expect(await family.hasSavedPlan(), isFalse);
      expect(await landmarks.load(), isEmpty);
    },
  );

  test('deleting seeded records does not seed them again', () async {
    await seeder().seed();
    await landmarks.deleteAll();
    await family.deleteAll();
    await seeder().seed();
    expect(await landmarks.load(), isEmpty);
    expect(await family.hasSavedPlan(), isFalse);
  });

  test(
    'interrupted seed resumes, preserves edits and replaces orphan copy',
    () async {
      final interrupted = _InterruptedLandmarkRepository(directory);
      await expectLater(
        seeder(repository: interrupted).seed(),
        throwsStateError,
      );
      expect(await storage.read(key: DemoDataSeeder.storageKey), 'pending');
      expect((await family.load()).safePoints.length, 3);
      // Empty fields may be intentional edits, even before seeding finishes.
      const editedChild = ChildProfile(fullName: 'Edited child');
      await family.save(
        (await family.load()).copyWith(
          child: editedChild,
          contacts: [],
          safePoints: [],
        ),
      );
      final saved = (await landmarks.load()).single;
      await landmarks.save(
        Landmark.fromJson({...saved.toJson(), 'name': 'Edited demo'}),
      );
      final photoDirectory = await landmarks.photoDirectory();
      await File(
        '${photoDirectory.path}/${demoLandmarks[1].landmark.photoName}',
      ).writeAsBytes([1, 2, 3]);

      await seeder(repository: interrupted).seed();
      final restoredPlan = await family.load();
      expect(restoredPlan.child.toJson(), editedChild.toJson());
      expect(restoredPlan.contacts, isEmpty);
      expect(restoredPlan.safePoints, isEmpty);
      final restored = await landmarks.load();
      expect(restored.length, 3);
      expect(restored.first.name, 'Edited demo');
      expect((await family.load()).practiceMeetingPoint!.label, 'Edited demo');
      expect(await storage.read(key: DemoDataSeeder.storageKey), 'complete');
    },
  );

  test(
    'failed pending data read surfaces an error and preserves the record',
    () async {
      const invalid = '{"version":99}';
      await storage.write(key: DemoDataSeeder.storageKey, value: 'pending');
      await storage.write(key: LandmarkRepository.storageKey, value: invalid);
      await expectLater(seeder().seed(), throwsFormatException);
      expect(await storage.read(key: LandmarkRepository.storageKey), invalid);
      expect(await storage.read(key: DemoDataSeeder.storageKey), 'pending');
    },
  );

  test(
    'old safe-place JSON defaults to ordinary data; demo flag round trips',
    () {
      final old = SafePoint.fromJson({
        'name': 'Existing',
        'latitude': 50,
        'longitude': 20,
      });
      expect(old.isDemo, isFalse);
      expect(SafePoint.fromJson(demoHome.toJson()).isDemo, isTrue);
      final plan = FamilyPlan.fromJson(
        FamilyPlan(safePoints: [demoHome]).toJson(),
      );
      expect(plan.safePoints.single.isDemo, isTrue);
    },
  );
}

class _InterruptedLandmarkRepository extends LandmarkRepository {
  _InterruptedLandmarkRepository(Directory directory)
    : super(supportDirectory: () async => directory);

  var _writes = 0;

  @override
  Future<void> save(
    Landmark landmark, {
    String? sourcePhoto,
    List<int>? photoBytes,
  }) async {
    if (++_writes == 2) throw StateError('Interrupted demo import');
    await super.save(
      landmark,
      sourcePhoto: sourcePhoto,
      photoBytes: photoBytes,
    );
  }
}
