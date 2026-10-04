import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mission_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const audioChannel = MethodChannel('test/mission_audio');
  final audioCalls = <MethodCall>[];

  setUp(() {
    audioCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call);
          return call.method == 'initialize' ? true : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, null);
  });

  testWidgets(
    'short quiz screens keep choices usable while advancing automatically',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final size in [
        const Size(320, 640),
        const Size(390, 844),
        const Size(800, 480),
      ]) {
        tester.view.physicalSize = size;
        await showMission(tester, audioChannel, MissionMode.home);
        for (final label in [
          'Znajdź miejsce',
          'Przejdź w głąb domu',
          'Wewnętrzny korytarz',
          'Mama',
        ]) {
          final action = find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.label == label,
          );
          final target = action.evaluate().isEmpty ? find.text(label) : action;
          final currentScene = tester.widget<MissionScene>(
            find.byType(MissionScene),
          );
          for (final choice in currentScene.choices) {
            final choiceTarget = find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics &&
                  widget.properties.label == choice.label,
            );
            final bounds = tester.getRect(choiceTarget);
            expect(bounds.top, greaterThanOrEqualTo(0));
            expect(bounds.bottom, lessThanOrEqualTo(size.height));
            expect(choiceTarget.hitTestable(), findsOneWidget);
          }
          expect(target.hitTestable(), findsOneWidget, reason: '$size: $label');
          await tester.tap(target);
          await tester.pumpAndSettle();
          if (tester
                  .widget<MissionScene>(find.byType(MissionScene))
                  .selectedChoice
                  ?.isCorrect ==
              true) {
            await finishMissionFeedback(tester);
          }
          expect(tester.takeException(), isNull, reason: '$size: $label');
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('outdoor poses work on compact screens and with large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final configuration in [
      (const Size(320, 640), 1.0),
      (const Size(800, 480), 1.0),
      (const Size(320, 700), 2.0),
    ]) {
      tester.view.physicalSize = configuration.$1;
      await showMission(
        tester,
        audioChannel,
        MissionMode.outdoor,
        textScale: configuration.$2,
      );
      for (final label in [
        'Wybierz, dokąd pójdziesz',
        'Dom: daleko',
        'Wybierz, co zrobisz',
        'Stój dalej',
        'Połóż się',
        'Zostaw ręce opuszczone',
        'Osłoń głowę',
        'Idź za dorosłym',
      ]) {
        await tapMissionAction(tester, label);
        expect(tester.takeException(), isNull, reason: label);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });

  testWidgets('narrow screens and large text keep room targets usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showMission(
      tester,
      audioChannel,
      MissionMode.home,
      textScale: 2,
      repository: PracticeRepository(
        contacts: const [TrustedContact(phone: '123 456 789')],
      ),
    );
    expect(tester.takeException(), isNull);
    await tapMissionAction(tester, 'Znajdź miejsce');
    expect(tester.takeException(), isNull);
    await tapMissionAction(tester, 'Przejdź w głąb domu');
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Salon',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Sypialnia',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.label == 'Kuchnia',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Wewnętrzny korytarz',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tapMissionAction(tester, 'Wewnętrzny korytarz');
    await tapMissionAction(tester, 'Babcia lub dziadek');
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Spróbuj zadzwonić raz',
      ),
      findsOneWidget,
    );
    await tapMissionAction(tester, 'Spróbuj zadzwonić raz');
    await tapMissionAction(tester, 'Wyślij SMS');
    for (final digit in '123456789'.split('')) {
      await tapMissionAction(tester, digit);
    }
    await tapMissionAction(tester, 'Sprawdź numer');
    await tapMissionAction(tester, 'Wyślij wiadomość na niby');
    expect(find.text('Rozmowa na niby'), findsOneWidget);
    await tapMissionAction(tester, 'Zostań tutaj');
    expect(find.text('Słyszysz głośny huk'), findsOneWidget);
    await tapMissionAction(tester, 'Zostań tutaj');
    await tapMissionAction(tester, 'Zostań i czekaj');
    await tapMissionAction(tester, 'Zapamiętaj kroki');
    expect(find.text('Czekaj na odwołanie alarmu'), findsOneWidget);
    await tester.ensureVisible(find.text('Zostań tam, nawet gdy jest cicho.'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tapMissionAction(tester, 'Zakończ ćwiczenie');
    expect(find.text('Ćwiczenie ukończone'), findsOneWidget);
    expect(find.text('Czekaj na odwołanie alarmu'), findsOneWidget);
    await tapMissionAction(tester, 'Ćwicz ponownie');
    expect(find.text('Alarm w domu'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
