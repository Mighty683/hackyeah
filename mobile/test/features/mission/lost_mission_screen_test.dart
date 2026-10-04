import 'dart:async';

import 'package:do_bazy/features/mission/data/lost_practice_context.dart';
import 'package:do_bazy/features/mission/lost_mission.dart';
import 'package:do_bazy/features/mission/lost_adult_sprite.dart';
import 'package:do_bazy/features/mission/scene_object_target.dart';
import 'package:do_bazy/features/mission/lost_mission_scene.dart';
import 'package:do_bazy/features/mission/lost_mission_screen.dart';
import 'package:do_bazy/audio/practice_audio.dart';
import 'package:do_bazy/features/mission/practice_recap.dart';
import 'package:do_bazy/features/mission/practice_contact_picker.dart';
import 'package:do_bazy/widgets/basebound_mascot.dart';
import 'package:do_bazy/widgets/child_character.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _context = LostPracticeContext(
  childName: 'Demo child',
  gender: ChildGender.girl,
  meetingPoint: PracticeMeetingPoint(
    presetId: 'information_desk',
    label: 'Our help desk',
  ),
  contacts: [
    LostPracticeContact(
      id: 'parent',
      label: 'Parent',
      avatar: LostContactAvatar.mother,
    ),
    LostPracticeContact(
      id: 'grandparent',
      label: 'Babcia lub dziadek',
      avatar: LostContactAvatar.grandparent,
    ),
  ],
  fictionalMeetingPoint: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/lost_audio');
  final audioCalls = <MethodCall>[];
  var voiceAvailable = true;

  setUp(() {
    voiceAvailable = true;
    audioCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          audioCalls.add(call);
          return call.method == 'initialize' ? voiceAvailable : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final variant in LostPracticeVariant.values) {
    testWidgets(
      '${variant.name} finishes with pretend confirmation and replays',
      (tester) async {
        await _show(tester, channel, variant);
        expect(find.text('Tylko ćwiczenie · 7+'), findsOneWidget);
        expect(find.text("JESTEM W BEZPIECZNYM MIEJSCU"), findsNothing);
        expect(_lastNarration(audioCalls), contains('Biegnij i szukaj'));
        expect(_lastNarration(audioCalls), contains('Zatrzymaj się i spójrz'));
        expect(
          find.descendant(
            of: find.byType(LostMissionScene),
            matching: find.byType(SceneObjectTarget),
          ),
          findsNWidgets(3),
        );

        await _choose(tester, 'search');
        expect(find.text('Spróbuj ponownie'), findsNothing);
        expect(find.byType(SceneObjectTarget), findsNWidgets(3));
        expect(
          tester
              .widget<SceneObjectTarget>(
                find.byKey(const ValueKey('lost-choice-search')),
              )
              .onTap,
          isNull,
        );
        expect(find.byKey(const ValueKey('lost-primary-action')), findsNothing);
        final feedback = _lastNarration(audioCalls);
        await tester.tap(find.byTooltip('Posłuchaj ponownie'));
        await tester.pumpAndSettle();
        expect(_lastNarration(audioCalls), feedback);
        expect(_stepId(tester), 'stop');
        await _choose(tester, 'stop');
        expect(_stepId(tester), 'look');
        final lookScene = tester.widget<LostMissionScene>(
          find.byType(LostMissionScene),
        );
        expect(
          lookScene.practiceContext.meetingPoint.presetId,
          'information_desk',
        );
        expect(find.textContaining('Our help desk'), findsOneWidget);
        await _next(tester);

        if (variant == LostPracticeVariant.meetingPointNearby) {
          expect(_stepId(tester), 'meeting_point');
          await _choose(tester, 'information_desk');
          expect(_stepId(tester), 'arrive');
          await _next(tester);
        } else {
          expect(_stepId(tester), 'point_unavailable');
          await _choose(tester, 'stay');
        }

        await _choose(tester, 'staff');
        await _choose(tester, 'stay');
        expect(_stepId(tester), 'contact');
        expect(find.byType(PracticeContactPicker), findsOneWidget);
        expect(find.text('Parent'), findsOneWidget);
        expect(find.text('Babcia lub dziadek'), findsOneWidget);
        await _choose(tester, 'parent');
        expect(_stepId(tester), 'no_answer');
        expect(find.byType(PracticeContactPicker), findsOneWidget);
        expect(find.byKey(const ValueKey('lost-choice-parent')), findsNothing);
        await _choose(tester, 'grandparent');
        expect(_stepId(tester), 'reply');
        await _next(tester);
        await _choose(tester, 'stay');
        expect(_stepId(tester), 'reunion');
        expect(find.text("JESTEM W BEZPIECZNYM MIEJSCU"), findsNothing);
        final reunionAction = tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('lost-primary-action')),
            )
            .onPressed!;
        reunionAction();
        reunionAction();
        await tester.pumpAndSettle();
        expect(_stepId(tester), 'confirm_safe');
        expect(find.text("JESTEM W BEZPIECZNYM MIEJSCU"), findsOneWidget);
        await _next(tester);
        expect(_stepId(tester), 'confirmation');
        expect(
          find.text('Ćwiczenie ukończone. Nie wysłano żadnej wiadomości.'),
          findsOneWidget,
        );
        await _next(tester);
        expect(find.text('Zapamiętaj ćwiczone kroki'), findsOneWidget);
        expect(find.byType(LostMissionScene), findsNothing);
        _expectRecap(tester);
        expect(_lastNarration(audioCalls), LostPracticeRecap.narration);
        await tester.tap(find.byTooltip('Posłuchaj ponownie'));
        await tester.pumpAndSettle();
        expect(_lastNarration(audioCalls), LostPracticeRecap.narration);
        await _next(tester);
        expect(find.text('Ćwiczenie ukończone'), findsOneWidget);
        _expectRecap(tester);
        expect(_lastNarration(audioCalls), LostPracticeRecap.narration);
        expect(
          audioCalls
              .where((call) => call.method == 'narrate')
              .every((call) => (call.arguments as Map)['sound'] == null),
          isTrue,
        );
        await tester.tap(find.byKey(const ValueKey('lost-restart')));
        await tester.pumpAndSettle();
        expect(_stepId(tester), 'stop');
        expect(find.text("JESTEM W BEZPIECZNYM MIEJSCU"), findsNothing);
        expect(tester.takeException(), isNull);
        await _remove(tester);
      },
    );
  }

  testWidgets('missing voice offers adult support, retry and usable choices', (
    tester,
  ) async {
    voiceAvailable = false;
    await _show(tester, channel, LostPracticeVariant.meetingPointUnavailable);
    expect(
      find.text(
        'Głos jest niedostępny. Poproś dorosłego o przeczytanie kolejnych kroków.',
      ),
      findsOneWidget,
    );
    final replay = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is IconButton && widget.tooltip == 'Posłuchaj ponownie',
      ),
    );
    expect(replay.onPressed, isNull);
    await _choose(tester, 'stop');
    expect(_stepId(tester), 'look');
    voiceAvailable = true;
    await _tapVisible(tester, find.text('Spróbuj włączyć głos ponownie'));
    expect(
      find.text(
        'Głos jest niedostępny. Poproś dorosłego o przeczytanie kolejnych kroków.',
      ),
      findsNothing,
    );
    expect(_lastNarration(audioCalls), contains('Our help desk'));
    expect(tester.takeException(), isNull);
    await _remove(tester);
  });

  testWidgets('background stops narration and exit disposes before returning', (
    tester,
  ) async {
    final pendingSpeech = Completer<void>();
    addTearDown(() {
      if (!pendingSpeech.isCompleted) pendingSpeech.complete();
    });
    var holdSpeech = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          audioCalls.add(call);
          if (call.method == 'initialize') return true;
          if (call.method == 'narrate' && holdSpeech) {
            await pendingSpeech.future;
          }
          return null;
        });
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LostMissionScreen(
                    variant: LostPracticeVariant.meetingPointNearby,
                    practiceContext: _context,
                    audio: PracticeAudio(channel: channel),
                  ),
                ),
              ),
              child: const Text('Open practice'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open practice'));
    await tester.pumpAndSettle();
    final stopCount = audioCalls.where((call) => call.method == 'stop').length;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(
      audioCalls.where((call) => call.method == 'stop').length,
      greaterThan(stopCount),
    );
    holdSpeech = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await _choose(tester, 'stop', advanceFeedback: false);
    await tester.tap(find.byTooltip('Opuść ćwiczenie'));
    await tester.pumpAndSettle();
    expect(find.byType(LostMissionScreen), findsNothing);
    expect(find.text('Open practice'), findsOneWidget);
    expect(audioCalls.where((call) => call.method == 'dispose').length, 1);
    pendingSpeech.complete();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _remove(tester);
  });

  testWidgets(
    'accepted feedback waits for narration and keeps story actions explicit',
    (tester) async {
      final feedbackSpeech = Completer<void>();
      addTearDown(() {
        if (!feedbackSpeech.isCompleted) feedbackSpeech.complete();
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            audioCalls.add(call);
            if (call.method == 'initialize') return true;
            if (call.method == 'narrate' &&
                (call.arguments as Map)['text'] ==
                    'Dobrze. Teraz stoisz. Rozejrzyj się.') {
              await feedbackSpeech.future;
            }
            return null;
          });
      await _show(tester, channel, LostPracticeVariant.meetingPointNearby);
      await _choose(tester, 'stop', advanceFeedback: false);
      await tester.pump(const Duration(seconds: 5));
      expect(_stepId(tester), 'stop');
      expect(find.byKey(const ValueKey('lost-primary-action')), findsNothing);
      expect(
        tester
            .widgetList<SceneObjectTarget>(find.byType(SceneObjectTarget))
            .every((target) => target.onTap == null),
        isTrue,
      );
      feedbackSpeech.complete();
      await tester.pumpAndSettle();
      expect(_stepId(tester), 'look');
      await tester.pump(const Duration(seconds: 5));
      expect(_stepId(tester), 'look');
      expect(find.byKey(const ValueKey('lost-primary-action')), findsOneWidget);
      await _remove(tester);
    },
  );

  testWidgets(
    'replay restarts the accepted-feedback pause without double advancement',
    (tester) async {
      await _show(tester, channel, LostPracticeVariant.meetingPointNearby);
      await _choose(tester, 'stop', advanceFeedback: false);
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byTooltip('Posłuchaj ponownie'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      expect(_stepId(tester), 'stop');
      await _finishFeedback(tester);
      expect(_stepId(tester), 'look');
      await _next(tester);
      expect(_stepId(tester), 'meeting_point');
      await tester.pump(const Duration(seconds: 4));
      expect(_stepId(tester), 'meeting_point');
      await _remove(tester);
    },
  );

  testWidgets(
    'silent accepted feedback pauses advancement while backgrounded',
    (tester) async {
      voiceAvailable = false;
      await _show(tester, channel, LostPracticeVariant.meetingPointNearby);
      await _choose(tester, 'stop', advanceFeedback: false);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 5));
      expect(_stepId(tester), 'stop');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(_stepId(tester), 'stop');
      await _finishFeedback(tester);
      expect(_stepId(tester), 'look');
      await _remove(tester);
    },
  );

  testWidgets(
    'short landscape keeps pictured choices and no-answer contacts reachable',
    (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _show(tester, channel, LostPracticeVariant.meetingPointUnavailable);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/illustrations/lost-square-v1.png',
        ),
        findsOneWidget,
      );
      expect(find.byType(ChildCharacter), findsNWidgets(2));
      await _choose(tester, 'stop');
      await _next(tester);
      expect(_stepId(tester), 'point_unavailable');
      await _choose(tester, 'stay');
      expect(_stepId(tester), 'helper');
      expect(
        tester
            .widgetList<LostAdultSprite>(find.byType(LostAdultSprite))
            .any((adult) => adult.pose == LostAdultPose.staff),
        isTrue,
      );
      await _choose(tester, 'staff');
      await _choose(tester, 'stay');
      expect(_stepId(tester), 'contact');
      expect(find.byType(PracticeContactPicker), findsOneWidget);
      await _choose(tester, 'parent');
      expect(_stepId(tester), 'no_answer');
      await _choose(tester, 'leave');
      expect(_stepId(tester), 'no_answer');
      final departure = tester.widget<SceneObjectTarget>(
        find.byKey(const ValueKey('lost-choice-leave')),
      );
      expect(departure.rejected, isTrue);
      expect(departure.onTap, isNull);
      final alternate = tester.widget<SceneObjectTarget>(
        find.byKey(const ValueKey('lost-choice-grandparent')),
      );
      expect(alternate.onTap, isNotNull);
      await _choose(tester, 'grandparent');
      expect(_stepId(tester), 'reply');
      expect(tester.takeException(), isNull);
      await _remove(tester);
    },
  );

  testWidgets(
    'narrow screen and large text retain targets and explicit story actions',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _show(
        tester,
        channel,
        LostPracticeVariant.meetingPointNearby,
        textScale: 2,
      );
      final choices = tester
          .widget<LostMissionScene>(find.byType(LostMissionScene))
          .step
          .choices;
      for (final choice in choices) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == choice.label &&
                widget.properties.onTap != null,
          ),
          findsOneWidget,
        );
        final target = find.byKey(ValueKey('lost-choice-${choice.id}'));
        final targetSize = tester.getSize(target);
        expect(targetSize.width, greaterThanOrEqualTo(48));
        expect(targetSize.height, greaterThanOrEqualTo(48));
        expect(
          find.descendant(of: find.byType(LostMissionScene), matching: target),
          findsOneWidget,
        );
      }
      await _choose(tester, 'stop');
      expect(
        find.byKey(const ValueKey('lost-primary-action')).hitTestable(),
        findsOneWidget,
      );
      expect(_stepId(tester), 'look');
      expect(
        find.byKey(const ValueKey('lost-primary-action')).hitTestable(),
        findsOneWidget,
      );
      await _next(tester);
      await _choose(tester, 'information_desk');
      expect(tester.takeException(), isNull);
      await _remove(tester);
    },
  );
}

void _expectRecap(WidgetTester tester) {
  expect(find.byType(PracticeRecap), findsOneWidget);
  expect(find.text(LostPracticeRecap.praise), findsOneWidget);
  expect(find.text(LostPracticeRecap.notice), findsOneWidget);
  for (final point in LostPracticeRecap.points) {
    expect(find.text(point.title), findsOneWidget);
    expect(find.text(point.description), findsOneWidget);
  }
  expect(
    tester.widget<BaseboundMascot>(find.byType(BaseboundMascot)).pose,
    DinoPose.celebrate,
  );
}

String _lastNarration(List<MethodCall> calls) =>
    (calls.lastWhere((call) => call.method == 'narrate').arguments
            as Map)['text']
        as String;

String _stepId(WidgetTester tester) =>
    tester.widget<LostMissionScene>(find.byType(LostMissionScene)).step.id;

Future<void> _show(
  WidgetTester tester,
  MethodChannel channel,
  LostPracticeVariant variant, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: LostMissionScreen(
        variant: variant,
        practiceContext: _context,
        audio: PracticeAudio(channel: channel),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _choose(
  WidgetTester tester,
  String id, {
  bool advanceFeedback = true,
}) async {
  await _tapVisible(tester, find.byKey(ValueKey('lost-choice-$id')));
  final scene = tester.widget<LostMissionScene>(find.byType(LostMissionScene));
  if (advanceFeedback && scene.selectedChoice?.isCorrect == true) {
    await _finishFeedback(tester);
  }
}

Future<void> _finishFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) =>
    _tapVisible(tester, find.byKey(const ValueKey('lost-primary-action')));

Future<void> _tapVisible(WidgetTester tester, Finder target) async {
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _remove(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}
