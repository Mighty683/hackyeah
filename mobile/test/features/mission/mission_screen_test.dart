import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/practice_phone_keypad.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/widgets/basebound_mascot.dart';
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

  testWidgets('home practice retries, speaks, finishes and replays', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await showMission(
      tester,
      audioChannel,
      MissionMode.home,
      repository: PracticeRepository(
        contacts: const [
          TrustedContact(name: 'Demo adult', phone: '987 654 321'),
          TrustedContact(name: 'Demo parent', phone: '+48 (123) 456-789'),
        ],
      ),
    );
    expect(find.text('An alarm at home'), findsOneWidget);
    final firstNarration = audioCalls.lastWhere(
      (call) => call.method == 'narrate',
    );
    await tapMissionAction(tester, 'Replay audio');
    final replayNarration = audioCalls.lastWhere(
      (call) => call.method == 'narrate',
    );
    expect(replayNarration.arguments, firstNarration.arguments);
    expect(audioCalls.where((call) => call.method == 'narrate').length, 2);

    await tapMissionAction(tester, 'Find a place');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).choices,
      hasLength(3),
    );
    await tapMissionAction(tester, 'Go to the window');
    expect(
      find.text('Windows are less safe. Move away from them.'),
      findsOneWidget,
    );
    expect(find.byType(BaseboundMascot), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Next step'), findsNothing);
    await tapMissionAction(tester, 'Move deeper inside');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).choices,
      hasLength(4),
    );
    await tapMissionAction(tester, 'Inside hallway', advanceFeedback: false);
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).visual,
      MissionVisual.twoWalls,
    );
    await finishMissionFeedback(tester);
    await tapMissionAction(tester, 'Mom');
    await tapMissionAction(tester, 'Keep calling');
    await tapMissionAction(tester, 'Send one message');
    expect(find.byType(PracticePhoneKeypad), findsOneWidget);
    expect(find.text('987 654 321'), findsNothing);
    await tapMissionAction(tester, '1');
    await tapMissionAction(tester, 'Check number');
    expect(
      find.text('That number does not match yet. Try again or use a hint.'),
      findsOneWidget,
    );
    expect(find.text('Send pretend message'), findsNothing);
    await tapMissionAction(tester, 'Need a hint?');
    expect(find.text('+48 (123) 456-789'), findsOneWidget);
    await tapMissionAction(tester, 'Hide hint');
    await tapMissionAction(tester, 'Clear number');
    for (final digit in '48123456780'.split('')) {
      await tapMissionAction(tester, digit);
    }
    await tester.ensureVisible(find.byTooltip('Delete last digit'));
    await tester.tap(find.byTooltip('Delete last digit'));
    await tester.pumpAndSettle();
    await tapMissionAction(tester, '9');
    await tapMissionAction(tester, 'Check number');
    expect(find.text('That matches a saved number.'), findsOneWidget);
    await tapMissionAction(tester, 'Send pretend message');
    expect(find.text('A pretend conversation'), findsOneWidget);
    expect(find.text('I am away from windows.'), findsOneWidget);
    expect(
      find.text('Good. Stay there and wait for the all-clear.'),
      findsOneWidget,
    );
    expect(find.text('Practice only. Nothing was sent.'), findsOneWidget);
    expect(find.text('Hear the reply'), findsNothing);
    await tapMissionAction(tester, 'Stay here');
    await tapMissionAction(tester, 'Stay here');
    final characterBefore = tester.widget<AnimatedPositioned>(
      find.byKey(const ValueKey('mission-character')),
    );
    await tapMissionAction(tester, 'Leave now');
    expect(find.textContaining('Stay inside your home.'), findsOneWidget);
    expect(find.byType(BaseboundMascot), findsOneWidget);
    expect(
      lastMissionNarration(audioCalls)['text'],
      contains('Stay inside your home.'),
    );
    final door = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'Leave now',
    );
    expect(tester.widget<Semantics>(door).properties.enabled, isFalse);
    final doorTapTarget = find.descendant(
      of: door,
      matching: find.byType(InkWell),
    );
    expect(tester.widget<InkWell>(doorTapTarget).onTap, isNull);
    final characterAfter = tester.widget<AnimatedPositioned>(
      find.byKey(const ValueKey('mission-character')),
    );
    expect(characterAfter.left, characterBefore.left);
    expect(characterAfter.top, characterBefore.top);
    await tapMissionAction(tester, 'Stay and wait', advanceFeedback: false);
    expect(
      find.text('Good. Stay inside your home. Wait for the all-clear.'),
      findsOneWidget,
    );
    expect(tester.widget<InkWell>(doorTapTarget).onTap, isNull);
    await finishMissionFeedback(tester);
    await tapMissionAction(tester, 'Remember the steps');
    expect(find.byType(MissionScene), findsNothing);
    expect(find.text('Wait for the all-clear'), findsOneWidget);
    expect(find.text(AirRaidPracticeRecap.praise), findsOneWidget);
    for (final point in AirRaidPracticeRecap.points) {
      expect(find.text(point.title), findsOneWidget);
      expect(find.text(point.description), findsOneWidget);
    }
    expect(
      tester.widget<BaseboundMascot>(find.byType(BaseboundMascot)).pose,
      DinoPose.celebrate,
    );
    expect(
      lastMissionNarration(audioCalls)['text'],
      AirRaidPracticeRecap.narration,
    );
    await tapMissionAction(tester, 'Finish practice');
    expect(find.text('Practice complete'), findsOneWidget);
    expect(find.text('Wait for the all-clear'), findsOneWidget);
    expect(find.text(AirRaidPracticeRecap.praise), findsOneWidget);
    expect(
      lastMissionNarration(audioCalls)['text'],
      AirRaidPracticeRecap.narration,
    );
    expect(
      audioCalls
          .where((call) => call.method == 'narrate')
          .any((call) => (call.arguments as Map)['sound'] == 'all_clear'),
      isTrue,
    );
    await tapMissionAction(tester, 'Play again');
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
    await showMission(tester, audioChannel, MissionMode.outdoor);
    await tapMissionAction(tester, 'Choose where to go');
    await tapMissionAction(tester, 'Home: far away', advanceFeedback: false);
    expect(lastMissionNarration(audioCalls)['sound'], 'select');
    await finishMissionFeedback(tester);
    expect(find.text('Still outside'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['text'], contains('towards home'));
    expect(lastMissionNarration(audioCalls)['sound'], 'noise');
    await tapMissionAction(tester, 'Choose what to do');
    expect(find.text('What will you do?'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['sound'], isNull);
    final scene = find.byType(MissionScene);
    await tester.ensureVisible(scene);
    await tester.drag(scene, const Offset(0, 90));
    await tester.pumpAndSettle();
    expect(find.text('You got down. Now protect your head.'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['sound'], 'action');
    await finishMissionFeedback(tester);
    await tapMissionAction(tester, 'Cover your head', advanceFeedback: false);
    expect(lastMissionNarration(audioCalls)['sound'], 'action');
    await finishMissionFeedback(tester);
    expect(find.text('An adult helps you'), findsOneWidget);
    await tapMissionAction(tester, 'Follow the adult');
    expect(find.text('Inside the practice shelter'), findsOneWidget);
    await tapMissionAction(tester, 'Tell a trusted adult');
    expect(find.text('Tell a trusted adult'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'phone practice handles missing numbers and retries failed reads',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = PracticeRepository(failRead: true);
      await showMission(
        tester,
        audioChannel,
        MissionMode.home,
        repository: repository,
        textScale: 2,
      );
      for (final label in [
        'Find a place',
        'Move deeper inside',
        'Inside hallway',
        'Mom',
        'Send one message',
      ]) {
        await tapMissionAction(tester, label);
      }
      expect(find.text('Try loading again'), findsOneWidget);
      expect(find.byType(PracticePhoneKeypad), findsNothing);
      repository.failRead = false;
      await tapMissionAction(tester, 'Try loading again');
      expect(find.byType(PracticePhoneKeypad), findsOneWidget);
      expect(
        find.text(
          'No phone number is saved yet. '
          'Ask an adult to add one in parent setup.',
        ),
        findsOneWidget,
      );
      await tapMissionAction(tester, 'Continue without a number');
      expect(find.text('A pretend conversation'), findsOneWidget);
      await tapMissionAction(tester, 'Stay here');
      expect(find.text('You hear a loud noise'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
