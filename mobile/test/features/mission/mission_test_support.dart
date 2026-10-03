import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:do_bazy/audio/practice_audio.dart';
import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/mission_screen.dart';
import 'package:do_bazy/features/mission/practice_phone_keypad.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:do_bazy/ui/basebound_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Map<dynamic, dynamic> lastMissionNarration(List<MethodCall> calls) =>
    calls.lastWhere((call) => call.method == 'narrate').arguments as Map;

Future<void> showMission(
  WidgetTester tester,
  MethodChannel channel,
  MissionMode mode, {
  double textScale = 1,
  FamilyPlanRepository? repository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: BaseboundTheme.training(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: MissionScreen(
        mode: mode,
        audio: PracticeAudio(channel: channel),
        repository: repository ?? PracticeRepository(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> finishMissionFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> tapMissionAction(
  WidgetTester tester,
  String label, {
  bool advanceFeedback = true,
}) async {
  final accessibleAction = find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );
  final target = accessibleAction.evaluate().isEmpty
      ? find.text(label)
      : accessibleAction;
  expect(target, findsOneWidget);
  final context = tester.element(find.byType(MissionScreen));
  if (MediaQuery.textScalerOf(context).scale(1) <= 1.1 &&
      find.byType(PracticePhoneKeypad).evaluate().isEmpty) {
    expect(target.hitTestable(), findsOneWidget, reason: label);
  } else {
    await tester.ensureVisible(target);
  }
  await tester.tap(target);
  await tester.pumpAndSettle();
  final sceneFinder = find.byType(MissionScene);
  if (advanceFeedback &&
      sceneFinder.evaluate().isNotEmpty &&
      (tester.widget<MissionScene>(sceneFinder).selectedChoice?.isCorrect ==
              true ||
          tester
                  .widget<MissionScene>(sceneFinder)
                  .selectedChoice
                  ?.continuesAfterFeedback ==
              true)) {
    await finishMissionFeedback(tester);
  }
  expectMissionChoicesAreUsable(tester);
}

class PracticeRepository extends FamilyPlanRepository {
  PracticeRepository({this.contacts = const [], this.failRead = false});

  final List<TrustedContact> contacts;
  bool failRead;

  @override
  Future<FamilyPlan> load() async {
    if (failRead) throw StateError('Demo read failure');
    return FamilyPlan(contacts: contacts);
  }
}

void expectMissionChoicesAreUsable(WidgetTester tester) {
  final sceneFinder = find.byType(MissionScene);
  if (sceneFinder.evaluate().isEmpty) return;
  final scene = tester.widget<MissionScene>(sceneFinder);
  final bounds = tester.getRect(sceneFinder);
  final targets = <Rect>[];
  for (final choice in scene.choices) {
    final target = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == choice.label,
    );
    expect(target, findsOneWidget);
    final rect = tester.getRect(target);
    expect(
      rect.left,
      greaterThanOrEqualTo(bounds.left - .5),
      reason: choice.label,
    );
    expect(
      rect.top,
      greaterThanOrEqualTo(bounds.top - .5),
      reason: choice.label,
    );
    expect(
      rect.right,
      lessThanOrEqualTo(bounds.right + .5),
      reason: choice.label,
    );
    expect(
      rect.bottom,
      lessThanOrEqualTo(bounds.bottom + .5),
      reason: choice.label,
    );
    expect(rect.width, greaterThanOrEqualTo(48), reason: choice.label);
    expect(rect.height, greaterThanOrEqualTo(48), reason: choice.label);
    for (final other in targets) {
      expect(rect.overlaps(other), isFalse, reason: choice.label);
    }
    targets.add(rect);
    final semantics = tester.widget<Semantics>(target).properties;
    final enabled =
        scene.onChoose != null && !scene.rejectedChoiceIds.contains(choice.id);
    expect(semantics.onTap, enabled ? isNotNull : isNull, reason: choice.label);
    expect(semantics.enabled, enabled, reason: choice.label);
  }
}
