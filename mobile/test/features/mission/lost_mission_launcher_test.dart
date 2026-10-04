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
      expect(find.text('Ćwiczenia'), findsOneWidget);
      expect(find.text('Nasza mapa'), findsOneWidget);
      expect(find.text('Landmark practice'), findsNothing);
      await _tap(tester, 'Ćwiczenia');
      expect(find.text('Ćwiczenie alarmu'), findsOneWidget);
      expect(find.text('Nasza mapa'), findsNothing);
      await _tap(tester, "Ćwiczenie zgubienia się");
      expect(
        find.text('Punkt spotkania do ćwiczeń: Blue help desk'),
        findsOneWidget,
      );
      await _tap(
        tester,
        variant == LostPracticeVariant.meetingPointNearby
            ? 'Punkt spotkania w pobliżu'
            : 'Punkt spotkania poza zasięgiem wzroku',
      );
      final mission = tester.widget<LostMissionScreen>(
        find.byType(LostMissionScreen),
      );
      expect(mission.variant, variant);
      expect(mission.practiceContext.meetingPoint.presetId, 'information_desk');
      expect(mission.practiceContext.contacts.first.label, 'Demo adult');
      // The scenario list must not resume its speech under the mission.
      expect((audioCalls.last.arguments as Map)['text'], contains('rodzica'));
      expect(
        (audioCalls.last.arguments as Map)['text'],
        isNot(contains('Wybierz scenariusz')),
      );
      await tester.tap(find.byTooltip('Opuść ćwiczenie'));
      await tester.pumpAndSettle();
      expect(find.byType(LostMissionLauncher), findsNothing);
      expect(find.text('Wybierz scenariusz'), findsOneWidget);
      expect(
        (audioCalls.last.arguments as Map)['text'],
        contains('Wybierz scenariusz'),
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
      expect(
        find.text('Nie udało się odczytać zapisanych danych rodziny.'),
        findsOneWidget,
      );
      expect(find.text('Punkt spotkania w pobliżu'), findsNothing);
      await _tap(tester, 'Spróbuj ponownie');
      expect(repository.reads, 2);
      expect(
        find.text('Nie udało się odczytać zapisanych danych rodziny.'),
        findsOneWidget,
      );
      await _tap(tester, 'Użyj rodziny na niby');
      expect(find.text('Część kontaktów jest fikcyjna.'), findsOneWidget);
      await _tap(tester, 'Punkt spotkania poza zasięgiem wzroku');
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
    await _tap(tester, 'Ćwiczenia');
    await _tap(tester, "Ćwiczenie zgubienia się");
    expect(
      find.text('Punkt spotkania do ćwiczeń: First point'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await repository.save(_configuredPlan);
    await _tap(tester, "Ćwiczenie zgubienia się");
    expect(
      find.text('Punkt spotkania do ćwiczeń: Blue help desk'),
      findsOneWidget,
    );
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
  contacts: [TrustedContact(name: 'Demo adult', relationship: 'Tata')],
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
