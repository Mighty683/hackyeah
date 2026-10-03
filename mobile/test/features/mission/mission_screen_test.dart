import 'dart:async';

import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:do_bazy/features/mission/mission_audio.dart';
import 'package:do_bazy/features/mission/mission_choice_card.dart';
import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/mission_screen.dart';
import 'package:do_bazy/ui/basebound_ui.dart';
import 'package:do_bazy/widgets/basebound_mascot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets('home practice retries, speaks, finishes and replays', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _showMission(tester, audioChannel, MissionMode.home);
    expect(find.text('An alarm at home'), findsOneWidget);
    final firstNarration = audioCalls.lastWhere(
      (call) => call.method == 'narrate',
    );
    await _tap(tester, 'Replay audio');
    final replayNarration = audioCalls.lastWhere(
      (call) => call.method == 'narrate',
    );
    expect(replayNarration.arguments, firstNarration.arguments);
    expect(audioCalls.where((call) => call.method == 'narrate').length, 2);

    await _tap(tester, 'Find a place');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).choices,
      hasLength(3),
    );
    expect(find.byType(MissionChoiceCard), findsNothing);
    await _tap(tester, 'Go to the window');
    expect(
      find.text('Windows are less safe. Move away from them.'),
      findsOneWidget,
    );
    expect(find.byType(BaseboundMascot), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Next step'), findsNothing);
    await _tap(tester, 'Move deeper inside');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).choices,
      hasLength(4),
    );
    expect(find.byType(MissionChoiceCard), findsNothing);
    await _tap(tester, 'Inside hallway', advanceFeedback: false);
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).visual,
      MissionVisual.twoWalls,
    );
    await _finishFeedback(tester);
    await _tap(tester, 'Mom');
    await _tap(tester, 'Send one message');
    await _tap(tester, 'Stay here');
    await _tap(tester, 'Stay here');
    await _tap(tester, 'Stay and wait');
    await _tap(tester, 'Remember the steps');
    await _tap(tester, 'Finish practice');
    expect(find.text('Practice complete'), findsOneWidget);
    expect(
      audioCalls
          .where((call) => call.method == 'narrate')
          .any((call) => (call.arguments as Map)['sound'] == 'all_clear'),
      isTrue,
    );
    await _tap(tester, 'Play again');
    expect(find.text('An alarm at home'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('outdoor story connects the destination, noise and recovery', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _showMission(tester, audioChannel, MissionMode.outdoor);
    await _tap(tester, 'Choose where to go');
    await _tap(tester, 'Home: far away', advanceFeedback: false);
    expect(_lastNarration(audioCalls)['sound'], 'select');
    await _finishFeedback(tester);
    expect(find.text('Still outside'), findsOneWidget);
    expect(_lastNarration(audioCalls)['text'], contains('towards home'));
    expect(_lastNarration(audioCalls)['sound'], 'noise');
    await _tap(tester, 'Choose what to do');
    expect(find.text('What will you do?'), findsOneWidget);
    expect(_lastNarration(audioCalls)['sound'], isNull);
    final scene = find.byType(MissionScene);
    await tester.ensureVisible(scene);
    await tester.drag(scene, const Offset(0, 90));
    await tester.pumpAndSettle();
    expect(find.text('You got down. Now protect your head.'), findsOneWidget);
    expect(_lastNarration(audioCalls)['sound'], 'action');
    await _finishFeedback(tester);
    await _tap(tester, 'Cover your head', advanceFeedback: false);
    expect(_lastNarration(audioCalls)['sound'], 'action');
    await _finishFeedback(tester);
    expect(find.text('An adult helps you'), findsOneWidget);
    await _tap(tester, 'Follow the adult');
    expect(find.text('Inside the practice shelter'), findsOneWidget);
    await _tap(tester, 'Tell a trusted adult');
    expect(find.text('Tell a trusted adult'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('sound effects can be muted while narration remains available', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _showMission(tester, audioChannel, MissionMode.home);
    expect(_lastNarration(audioCalls)['sound'], 'alarm');
    final initialText = _lastNarration(audioCalls)['text'];

    await tester.tap(find.byTooltip('Mute sound effects'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Unmute sound effects'), findsOneWidget);
    expect(_lastNarration(audioCalls)['text'], initialText);
    expect(_lastNarration(audioCalls)['sound'], isNull);
    await _tap(tester, 'Replay audio');
    expect(_lastNarration(audioCalls)['text'], initialText);
    expect(_lastNarration(audioCalls)['sound'], isNull);

    await _tap(tester, 'Find a place');
    await _tap(tester, 'Move deeper inside', advanceFeedback: false);
    expect(_lastNarration(audioCalls)['text'], contains('moved away'));
    expect(_lastNarration(audioCalls)['sound'], isNull);
    await tester.tap(find.byTooltip('Unmute sound effects'));
    await tester.pumpAndSettle();
    expect(_lastNarration(audioCalls)['sound'], 'success');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(audioCalls.last.method, 'stop');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(_lastNarration(audioCalls)['sound'], 'success');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(audioCalls.last.method, 'dispose');
  });

  testWidgets('sound cues still play and mute without an offline voice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call);
          return call.method == 'initialize' ? false : null;
        });
    await _showMission(tester, audioChannel, MissionMode.outdoor);
    expect(find.textContaining('The voice is unavailable'), findsOneWidget);
    expect(_lastNarration(audioCalls)['text'], isEmpty);
    expect(_lastNarration(audioCalls)['sound'], 'alarm');
    await _tap(tester, 'Replay audio');
    expect(_lastNarration(audioCalls)['sound'], 'alarm');
    await tester.tap(find.byTooltip('Mute sound effects'));
    await tester.pumpAndSettle();
    expect(audioCalls.last.method, 'stop');
    final replay = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Replay audio',
      ),
    );
    expect(replay.properties.enabled, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(audioCalls.last.method, 'dispose');
  });

  testWidgets('correct feedback waits for narration without confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final feedbackVoice = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call);
          if (call.method == 'initialize') return true;
          if (call.method == 'narrate' &&
              (call.arguments as Map)['text'] ==
                  'You reached the nearby practice shelter, away from windows.') {
            await feedbackVoice.future;
          }
          return null;
        });
    await _showMission(tester, audioChannel, MissionMode.outdoor);
    await _tap(tester, 'Choose where to go');
    await _tap(tester, 'Nearby solid shelter', advanceFeedback: false);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Where will you go?'), findsOneWidget);
    expect(find.text('Next step'), findsNothing);
    feedbackVoice.complete();
    await tester.pumpAndSettle();
    expect(find.text('Inside the practice shelter'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'silent feedback pauses automatic advancement in the background',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (call) async => false);
      await _showMission(tester, audioChannel, MissionMode.outdoor);
      await _tap(tester, 'Choose where to go');
      await _tap(tester, 'Nearby solid shelter', advanceFeedback: false);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Where will you go?'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Where will you go?'), findsOneWidget);
      await _finishFeedback(tester);
      expect(find.text('Inside the practice shelter'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

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
        await _showMission(tester, audioChannel, MissionMode.home);
        for (final label in [
          'Find a place',
          'Move deeper inside',
          'Inside hallway',
          'Mom',
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
            await _finishFeedback(tester);
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
      await _showMission(
        tester,
        audioChannel,
        MissionMode.outdoor,
        textScale: configuration.$2,
      );
      for (final label in [
        'Choose where to go',
        'Home: far away',
        'Choose what to do',
        'Keep standing',
        'Get down',
        'Keep hands down',
        'Cover your head',
        'Follow the adult',
      ]) {
        await _tap(tester, label);
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
    await _showMission(tester, audioChannel, MissionMode.home, textScale: 2);
    expect(tester.takeException(), isNull);
    await _tap(tester, 'Find a place');
    expect(tester.takeException(), isNull);
    await _tap(tester, 'Move deeper inside');
    expect(find.text('Living room'), findsOneWidget);
    expect(find.text('Bedroom'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);
    expect(find.text('Inside hallway'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _tap(tester, 'Inside hallway');
    await _tap(tester, 'Grandparent');
    expect(find.text('Send one message'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Map<dynamic, dynamic> _lastNarration(List<MethodCall> calls) =>
    calls.lastWhere((call) => call.method == 'narrate').arguments as Map;

Future<void> _showMission(
  WidgetTester tester,
  MethodChannel channel,
  MissionMode mode, {
  double textScale = 1,
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
        audio: MissionAudio(channel: channel),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _finishFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

Future<void> _tap(
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
  if (MediaQuery.textScalerOf(context).scale(1) <= 1.1) {
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
    await _finishFeedback(tester);
  }
  _expectMissionChoicesAreUsable(tester);
}

// Each choice is an independent accessible target inside the scene image.
void _expectMissionChoicesAreUsable(WidgetTester tester) {
  final sceneFinder = find.byType(MissionScene);
  if (sceneFinder.evaluate().isEmpty) return;
  final scene = tester.widget<MissionScene>(sceneFinder);
  final bounds = tester.getRect(sceneFinder);
  final targets = <Rect>[];
  expect(find.byType(MissionChoiceCard), findsNothing);
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
