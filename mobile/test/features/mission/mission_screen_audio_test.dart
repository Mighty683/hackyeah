import 'dart:async';

import 'package:do_bazy/features/mission/air_raid_mission.dart';
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

  testWidgets('sound effects can be muted while narration remains available', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showMission(tester, audioChannel, MissionMode.home);
    expect(lastMissionNarration(audioCalls)['sound'], 'alarm');
    final initialText = lastMissionNarration(audioCalls)['text'];

    await tester.tap(find.byTooltip('Mute sound effects'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Unmute sound effects'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['text'], initialText);
    expect(lastMissionNarration(audioCalls)['sound'], isNull);
    await tapMissionAction(tester, 'Replay audio');
    expect(lastMissionNarration(audioCalls)['text'], initialText);
    expect(lastMissionNarration(audioCalls)['sound'], isNull);

    await tapMissionAction(tester, 'Find a place');
    await tapMissionAction(
      tester,
      'Move deeper inside',
      advanceFeedback: false,
    );
    expect(lastMissionNarration(audioCalls)['text'], contains('moved away'));
    expect(lastMissionNarration(audioCalls)['sound'], isNull);
    await tester.tap(find.byTooltip('Unmute sound effects'));
    await tester.pumpAndSettle();
    expect(lastMissionNarration(audioCalls)['sound'], 'success');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(audioCalls.last.method, 'stop');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(lastMissionNarration(audioCalls)['sound'], 'success');
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
    await showMission(tester, audioChannel, MissionMode.outdoor);
    expect(find.textContaining('The voice is unavailable'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['text'], isEmpty);
    expect(lastMissionNarration(audioCalls)['sound'], 'alarm');
    await tapMissionAction(tester, 'Replay audio');
    expect(lastMissionNarration(audioCalls)['sound'], 'alarm');
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
    await showMission(tester, audioChannel, MissionMode.outdoor);
    await tapMissionAction(tester, 'Choose where to go');
    await tapMissionAction(
      tester,
      'Nearby solid shelter',
      advanceFeedback: false,
    );
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
      await showMission(tester, audioChannel, MissionMode.outdoor);
      await tapMissionAction(tester, 'Choose where to go');
      await tapMissionAction(
        tester,
        'Nearby solid shelter',
        advanceFeedback: false,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Where will you go?'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Where will you go?'), findsOneWidget);
      await finishMissionFeedback(tester);
      expect(find.text('Inside the practice shelter'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
