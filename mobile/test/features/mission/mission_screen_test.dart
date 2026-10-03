import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:do_bazy/features/mission/mission_audio.dart';
import 'package:do_bazy/features/mission/mission_choice_card.dart';
import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/mission_screen.dart';
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
      tester.widget<MissionScene>(find.byType(MissionScene)).choices.length,
      3,
    );
    await _tap(tester, 'Go to the window');
    expect(
      find.text('Windows are less safe. Move away from them.'),
      findsOneWidget,
    );
    await _tap(tester, 'Try again');
    await _tap(tester, 'Move deeper inside');
    await _tap(tester, 'Next step');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).choices.length,
      4,
    );
    await _tap(tester, 'Inside hallway');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).visual,
      MissionVisual.twoWalls,
    );
    await _tap(tester, 'Next step');
    await _tap(tester, 'Mom');
    await _tap(tester, 'Tell them');
    await _tap(tester, 'Send one message');
    await _tap(tester, 'Hear the reply');
    await _tap(tester, 'Stay here');
    await _tap(tester, 'Stay here');
    await _tap(tester, 'Keep waiting');
    await _tap(tester, 'Stay and wait');
    await _tap(tester, 'Wait for the all-clear');
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

  testWidgets('outdoor destination mistake supports drag and head protection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _showMission(tester, audioChannel, MissionMode.outdoor);
    await _tap(tester, 'Choose where to go');
    await _tap(tester, 'Home: far away');
    await _tap(tester, 'Next step');
    expect(find.text('A loud noise outside'), findsOneWidget);
    final scene = find.byType(MissionScene);
    await tester.ensureVisible(scene);
    await tester.drag(scene, const Offset(0, 90));
    await tester.pumpAndSettle();
    expect(find.text('You got down. Now protect your head.'), findsOneWidget);
    await _tap(tester, 'Next step');
    await _tap(tester, 'Cover your head');
    await _tap(tester, 'Next step');
    expect(find.text('Inside the practice shelter'), findsOneWidget);
    await _tap(tester, 'Keep waiting');
    expect(find.text('Tell a trusted adult'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('short quiz screens keep choices and next button in view', (
    tester,
  ) async {
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
        'Next step',
        'Inside hallway',
        'Next step',
        'Mom',
        'Tell them',
      ]) {
        final action = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == label,
        );
        final target = action.evaluate().isEmpty ? find.text(label) : action;
        for (final card in tester.widgetList<MissionChoiceCard>(
          find.byType(MissionChoiceCard),
        )) {
          final choice = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == card.choice.label,
          );
          final bounds = tester.getRect(choice);
          expect(bounds.top, greaterThanOrEqualTo(0));
          expect(bounds.bottom, lessThanOrEqualTo(size.height));
          expect(choice.hitTestable(), findsOneWidget);
        }
        expect(target.hitTestable(), findsOneWidget, reason: '$size: $label');
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$size: $label');
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
    await _tap(tester, 'Next step');
    expect(find.text('Living room'), findsOneWidget);
    expect(find.text('Bedroom'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);
    expect(find.text('Inside hallway'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _tap(tester, 'Inside hallway');
    await _tap(tester, 'Next step');
    await _tap(tester, 'Grandparent');
    await _tap(tester, 'Tell them');
    expect(find.text('Send one message'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

Future<void> _showMission(
  WidgetTester tester,
  MethodChannel channel,
  MissionMode mode, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
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

Future<void> _tap(WidgetTester tester, String label) async {
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
  _expectSceneChoicesAreUsable(tester);
}

// Scene choices must remain attached to the illustration and independently
// actionable as the journey changes between room, phone and outdoor scenes.
void _expectSceneChoicesAreUsable(WidgetTester tester) {
  final sceneFinder = find.byType(MissionScene);
  if (sceneFinder.evaluate().isEmpty) return;
  final scene = tester.widget<MissionScene>(sceneFinder);
  if (scene.selectedChoice != null) return;
  final bounds = tester.getRect(sceneFinder).inflate(.5);
  for (final choice in scene.choices) {
    final target = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == choice.label,
    );
    expect(target, findsOneWidget);
    final rect = tester.getRect(target);
    expect(bounds.contains(rect.topLeft), isTrue, reason: choice.label);
    expect(bounds.contains(rect.bottomRight), isTrue, reason: choice.label);
    expect(rect.width, greaterThanOrEqualTo(48), reason: choice.label);
    expect(rect.height, greaterThanOrEqualTo(48), reason: choice.label);
    final semantics = tester.widget<Semantics>(target).properties;
    expect(semantics.onTap, isNotNull, reason: choice.label);
    expect(semantics.enabled, isTrue, reason: choice.label);
  }
}
