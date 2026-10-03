import 'dart:async';

import 'package:do_bazy/features/mission/data/lost_practice_context.dart';
import 'package:do_bazy/features/mission/lost_landmarks.dart';
import 'package:do_bazy/features/mission/lost_mission.dart';
import 'package:do_bazy/features/mission/lost_mission_choice_card.dart';
import 'package:do_bazy/features/mission/lost_mission_scene.dart';
import 'package:do_bazy/features/mission/lost_mission_screen.dart';
import 'package:do_bazy/features/mission/mission_audio.dart';
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
      label: 'Grandparent',
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
        expect(find.text('Practice only · 7+'), findsOneWidget);
        expect(find.text("I'M SAFE"), findsNothing);
        expect(_lastNarration(audioCalls), contains('Run and search'));
        expect(_lastNarration(audioCalls), contains('Stop and look'));

        await _choose(tester, 'search');
        expect(find.text('Try again'), findsOneWidget);
        expect(find.byType(LostMissionChoiceCard), findsNothing);
        final feedback = _lastNarration(audioCalls);
        await tester.tap(find.byTooltip('Replay audio'));
        await tester.pumpAndSettle();
        expect(_lastNarration(audioCalls), feedback);
        await _next(tester);
        expect(_stepId(tester), 'stop');
        await _choose(tester, 'stop');
        await _next(tester);
        expect(_stepId(tester), 'look');
        final landmark = tester.widget<LostLandmarkIllustration>(
          find.byType(LostLandmarkIllustration),
        );
        expect(landmark.presetId, 'information_desk');
        expect(find.textContaining('Our help desk'), findsOneWidget);
        await _next(tester);

        if (variant == LostPracticeVariant.meetingPointNearby) {
          expect(_stepId(tester), 'meeting_point');
          await _choose(tester, 'information_desk');
          await _next(tester);
          expect(_stepId(tester), 'arrive');
          await _next(tester);
        } else {
          expect(_stepId(tester), 'point_unavailable');
          await _choose(tester, 'stay');
          await _next(tester);
        }

        await _choose(tester, 'staff');
        await _next(tester);
        await _choose(tester, 'stay');
        await _next(tester);
        expect(_stepId(tester), 'contact');
        await _choose(tester, 'parent');
        await _next(tester);
        expect(_stepId(tester), 'no_answer');
        expect(find.byKey(const ValueKey('lost-choice-parent')), findsNothing);
        await _choose(tester, 'grandparent');
        await _next(tester);
        expect(_stepId(tester), 'reply');
        await _next(tester);
        await _choose(tester, 'stay');
        await _next(tester);
        expect(_stepId(tester), 'reunion');
        expect(find.text("I'M SAFE"), findsNothing);
        await _next(tester);
        expect(_stepId(tester), 'confirm_safe');
        expect(find.text("I'M SAFE"), findsOneWidget);
        await _next(tester);
        expect(_stepId(tester), 'confirmation');
        expect(
          find.text('Practice complete. No message was sent.'),
          findsOneWidget,
        );
        await _next(tester);
        expect(_stepId(tester), 'recall');
        await _next(tester);
        expect(find.text('Practice complete'), findsOneWidget);
        expect(find.text('No message was sent.'), findsOneWidget);
        expect(
          audioCalls
              .where((call) => call.method == 'narrate')
              .every((call) => (call.arguments as Map)['sound'] == null),
          isTrue,
        );
        await tester.tap(find.byKey(const ValueKey('lost-restart')));
        await tester.pumpAndSettle();
        expect(_stepId(tester), 'stop');
        expect(find.text("I'M SAFE"), findsNothing);
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
        'The voice is unavailable. Ask an adult to read each step with you.',
      ),
      findsOneWidget,
    );
    final replay = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Replay audio',
      ),
    );
    expect(replay.onPressed, isNull);
    await _choose(tester, 'stop');
    await _next(tester);
    expect(_stepId(tester), 'look');
    voiceAvailable = true;
    await _tapVisible(tester, find.text('Try the voice again'));
    expect(
      find.text(
        'The voice is unavailable. Ask an adult to read each step with you.',
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
                    audio: MissionAudio(channel: channel),
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
    await tester.tap(find.byTooltip('Leave practice'));
    await tester.pumpAndSettle();
    expect(find.byType(LostMissionScreen), findsNothing);
    expect(find.text('Open practice'), findsOneWidget);
    expect(audioCalls.where((call) => call.method == 'dispose').length, 1);
    pendingSpeech.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _remove(tester);
  });

  testWidgets(
    'narrow screen and large text retain labelled controls and fixed next action',
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
      for (final card in tester.widgetList<LostMissionChoiceCard>(
        find.byType(LostMissionChoiceCard),
      )) {
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == card.choice.label &&
                widget.properties.onTap != null,
          ),
          findsOneWidget,
        );
      }
      await _choose(tester, 'stop');
      expect(
        find.byKey(const ValueKey('lost-primary-action')).hitTestable(),
        findsOneWidget,
      );
      await _next(tester);
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
        audio: MissionAudio(channel: channel),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, String id) =>
    _tapVisible(tester, find.byKey(ValueKey('lost-choice-$id')));

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
