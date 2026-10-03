import 'package:do_bazy/features/mission/lost_mission.dart';
import 'package:do_bazy/features/mission/lost_mission_launcher.dart';
import 'package:do_bazy/features/mission/lost_mission_screen.dart';
import 'package:do_bazy/features/mission/practice_launcher.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('basebound/mission_audio');
  final audioCalls = <MethodCall>[];

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    audioCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          audioCalls.add(call);
          return call.method == 'initialize' ? true : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final variant in LostPracticeVariant.values) {
    testWidgets('lost entry opens ${variant.name} and returns directly', (
      tester,
    ) async {
      await FamilyPlanRepository().save(_configuredPlan);
      await tester.pumpWidget(const MaterialApp(home: PracticeLauncher()));
      await tester.pumpAndSettle();
      expect(find.text('Alarm practice'), findsOneWidget);
      expect(find.text('Our map'), findsOneWidget);
      expect(find.text('Landmark practice'), findsNothing);
      await _tap(tester, "I'm lost practice");
      expect(
        find.text('Practice meeting point: Blue help desk'),
        findsOneWidget,
      );
      await _tap(
        tester,
        variant == LostPracticeVariant.meetingPointNearby
            ? 'Meeting point nearby'
            : 'Meeting point out of sight',
      );
      final mission = tester.widget<LostMissionScreen>(
        find.byType(LostMissionScreen),
      );
      expect(mission.variant, variant);
      expect(mission.practiceContext.meetingPoint.presetId, 'information_desk');
      expect(mission.practiceContext.contacts.first.label, 'Demo adult');
      // The activity launcher must not resume its speech under the mission.
      expect((audioCalls.last.arguments as Map)['text'], contains('parent'));
      expect(
        (audioCalls.last.arguments as Map)['text'],
        isNot(contains('Choose your practice')),
      );
      await tester.tap(find.byTooltip('Leave practice'));
      await tester.pumpAndSettle();
      expect(find.byType(LostMissionLauncher), findsNothing);
      expect(find.text('Choose practice'), findsOneWidget);
      expect(
        (audioCalls.last.arguments as Map)['text'],
        contains('Choose your practice'),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }

  testWidgets(
    'failed read needs an explicit fallback and never writes records',
    (tester) async {
      final repository = _FailingReadRepository();
      await tester.pumpWidget(
        MaterialApp(home: LostMissionLauncher(repository: repository)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Could not read saved family details.'), findsOneWidget);
      expect(find.text('Meeting point nearby'), findsNothing);
      await _tap(tester, 'Try again');
      expect(repository.reads, 2);
      expect(find.text('Could not read saved family details.'), findsOneWidget);
      await _tap(tester, 'Use pretend family');
      expect(find.text('Some family details are pretend.'), findsOneWidget);
      await _tap(tester, 'Meeting point out of sight');
      final mission = tester.widget<LostMissionScreen>(
        find.byType(LostMissionScreen),
      );
      expect(mission.practiceContext.fictionalMeetingPoint, isTrue);
      expect(
        mission.practiceContext.contacts.every(
          (contact) => contact.isFictional,
        ),
        isTrue,
      );
      expect(repository.writes, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('re-entering lost practice reloads the latest parent selection', (
    tester,
  ) async {
    final repository = FamilyPlanRepository();
    await repository.save(
      const FamilyPlan(
        practiceMeetingPoint: PracticeMeetingPoint(
          presetId: 'fountain',
          label: 'First point',
        ),
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: PracticeLauncher()));
    await tester.pumpAndSettle();
    await _tap(tester, "I'm lost practice");
    expect(find.text('Practice meeting point: First point'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await repository.save(_configuredPlan);
    await _tap(tester, "I'm lost practice");
    expect(find.text('Practice meeting point: Blue help desk'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

const _configuredPlan = FamilyPlan(
  practiceMeetingPoint: PracticeMeetingPoint(
    presetId: 'information_desk',
    label: 'Blue help desk',
  ),
  contacts: [TrustedContact(name: 'Demo adult', relationship: 'Father')],
);

class _FailingReadRepository extends FamilyPlanRepository {
  int reads = 0;
  int writes = 0;

  @override
  Future<FamilyPlan> load() async {
    ++reads;
    throw const FormatException('Test unreadable record');
  }

  @override
  Future<void> save(FamilyPlan plan) async => ++writes;
}

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
