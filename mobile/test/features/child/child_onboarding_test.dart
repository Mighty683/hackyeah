import 'package:do_bazy/features/child/child_onboarding_screen.dart';
import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:do_bazy/features/mission/mission_screen.dart';
import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/practice_launcher.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryRepository extends FamilyPlanRepository {
  FamilyPlan plan = const FamilyPlan(
    child: ChildProfile(address: 'Demo home', supportNotes: 'Demo note'),
    contacts: [TrustedContact(name: 'Demo adult')],
    safePoints: [SafePoint(name: 'Practice', latitude: 50, longitude: 20)],
    practiceMeetingPoint: PracticeMeetingPoint(
      presetId: 'information_desk',
      label: 'Demo help desk',
    ),
  );
  bool failSave = false;
  @override
  Future<FamilyPlan> load() async => plan;
  @override
  Future<void> save(FamilyPlan value) async {
    if (failSave) throw StateError('Storage unavailable');
    plan = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('basebound/mission_audio'),
          (call) async => call.method == 'initialize' ? true : null,
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('basebound/mission_audio'),
          null,
        );
  });

  test('old child records load without gender; new gender round trips', () {
    final json = const ChildProfile(fullName: 'Demo', age: 9).toJson()
      ..remove('gender');
    expect(ChildProfile.fromJson(json).gender, isNull);
    expect(
      ChildProfile.fromJson(
        const ChildProfile(gender: ChildGender.boy).toJson(),
      ).gender,
      ChildGender.boy,
    );
  });

  for (final gender in ChildGender.values) {
    testWidgets('${gender.name} onboarding saves and opens matching mission', (
      tester,
    ) async {
      final repository = _MemoryRepository();
      await tester.pumpWidget(
        MaterialApp(home: ChildOnboardingScreen(repository: repository)),
      );
      await tester.pumpAndSettle();
      if (gender == ChildGender.boy) {
        await _tap(tester, 'Add my name');
        expect(
          find.text('Please tell us your age to continue.'),
          findsOneWidget,
        );
        await tester.enterText(find.byType(TextField), '0');
        await _tap(tester, 'Add my name');
        expect(
          find.text('Please tell us your age to continue.'),
          findsOneWidget,
        );
      }
      await tester.enterText(find.byType(TextField), '9');
      await _tap(tester, 'Add my name');
      if (gender == ChildGender.boy) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '9',
        );
        await _tap(tester, 'Add my name');
        await _tap(tester, 'Choose my character');
        expect(find.text('Add your name or a nickname.'), findsOneWidget);
      }
      await tester.enterText(find.byType(TextField), 'Demo child');
      await _tap(tester, 'Choose my character');
      await _tap(tester, gender == ChildGender.boy ? 'Boy' : 'Girl');
      if (gender == ChildGender.boy) {
        repository.failSave = true;
        await _tap(tester, 'Start practice');
        expect(
          find.text('Could not save your details. Try again.'),
          findsOneWidget,
        );
        repository.failSave = false;
      }
      await _tap(tester, 'Start practice');
      expect(find.byType(PracticeLauncher), findsOneWidget);
      expect(repository.plan.child.fullName, 'Demo child');
      expect(repository.plan.child.age, 9);
      expect(repository.plan.child.gender, gender);
      expect(repository.plan.child.address, 'Demo home');
      expect(repository.plan.child.supportNotes, 'Demo note');
      expect(repository.plan.contacts.single.name, 'Demo adult');
      expect(repository.plan.safePoints.single.name, 'Practice');
      expect(
        repository.plan.practiceMeetingPoint!.presetId,
        'information_desk',
      );
      expect(repository.plan.practiceMeetingPoint!.label, 'Demo help desk');
      await _tap(tester, 'Practices');
      await _tap(tester, 'Alarm practice');
      await _tap(tester, 'At home');
      final mission = tester.widget<MissionScreen>(find.byType(MissionScreen));
      expect(mission.mode, MissionMode.home);
      expect(mission.gender, gender);
      expect(
        tester.widget<MissionScene>(find.byType(MissionScene)).gender,
        gender,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}

Future<void> _tap(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
