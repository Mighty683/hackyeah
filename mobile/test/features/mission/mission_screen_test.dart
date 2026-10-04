import 'dart:async';

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

  testWidgets('incorrect number shows one hint above the keypad', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PracticePhoneKeypad(
              contacts: const [
                TrustedContact(name: 'Mama', phone: '123 456 789'),
                TrustedContact(name: 'Tata', phone: '987 654 321'),
              ],
              onComplete: () {},
              onInstructionChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('1').first);
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sprawdź numer').first);
    await tester.tap(find.text('Sprawdź numer').first);
    await tester.pumpAndSettle();
    expect(find.text('123 456 789'), findsOneWidget);
    expect(find.text('987 654 321'), findsNothing);
    expect(
      tester.getTopLeft(find.text('123 456 789')).dy,
      lessThan(tester.getTopLeft(find.widgetWithText(OutlinedButton, '1')).dy),
    );
    await tester.ensureVisible(find.text('2').first);
    await tester.tap(find.text('2').first);
    await tester.pumpAndSettle();
    expect(find.text('123 456 789'), findsOneWidget);
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
          TrustedContact(name: 'Demo parent', phone: '+48 (123) 456-789'),
          TrustedContact(name: 'Demo adult', phone: '987 654 321'),
        ],
      ),
    );
    expect(find.text('Alarm w domu'), findsOneWidget);
    final firstNarration = audioCalls.lastWhere(
      (call) => call.method == 'narrate',
    );
    await tapMissionAction(tester, 'Posłuchaj ponownie');
    final replayNarration = audioCalls.lastWhere(
      (call) => call.method == 'narrate',
    );
    expect(replayNarration.arguments, firstNarration.arguments);
    expect(audioCalls.where((call) => call.method == 'narrate').length, 2);

    await tapMissionAction(tester, 'Znajdź miejsce');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).choices,
      hasLength(3),
    );
    await tapMissionAction(tester, 'Podejdź do okna');
    expect(
      find.text('Przy oknach jest mniej bezpiecznie. Odsuń się od nich.'),
      findsOneWidget,
    );
    expect(find.byType(BaseboundMascot), findsNothing);
    expect(find.text('Spróbuj ponownie'), findsNothing);
    expect(find.text('Następny krok'), findsNothing);
    await tapMissionAction(tester, 'Przejdź w głąb domu');
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).choices,
      hasLength(4),
    );
    await tapMissionAction(
      tester,
      'Wewnętrzny korytarz',
      advanceFeedback: false,
    );
    expect(
      tester.widget<MissionScene>(find.byType(MissionScene)).visual,
      MissionVisual.twoWalls,
    );
    await finishMissionFeedback(tester);
    await tapMissionAction(tester, 'Mama');
    expect(find.text('Wyślij SMS'), findsNothing);
    await tapMissionAction(
      tester,
      'Spróbuj zadzwonić raz',
      advanceFeedback: false,
    );
    expect(find.byType(PracticePhoneKeypad), findsOneWidget);
    expect(find.text('987 654 321'), findsNothing);
    await tapMissionAction(tester, '1');
    await tapMissionAction(tester, 'Sprawdź numer');
    expect(
      find.text('Numer jeszcze się nie zgadza. Wpisz pokazany numer.'),
      findsOneWidget,
    );
    expect(find.text('Zadzwoń na niby'), findsNothing);
    expect(find.text('+48 (123) 456-789'), findsOneWidget);
    expect(find.text('987 654 321'), findsNothing);
    expect(
      tester.getTopLeft(find.text('+48 (123) 456-789')).dy,
      lessThan(tester.getTopLeft(find.widgetWithText(OutlinedButton, '1')).dy),
    );
    await tapMissionAction(tester, 'Ukryj podpowiedź');
    await tapMissionAction(tester, 'Wyczyść numer');
    for (final digit in '48123456780'.split('')) {
      await tapMissionAction(tester, digit);
    }
    await tester.ensureVisible(find.byTooltip('Usuń ostatnią cyfrę'));
    await tester.tap(find.byTooltip('Usuń ostatnią cyfrę'));
    await tester.pumpAndSettle();
    await tapMissionAction(tester, '9');
    await tapMissionAction(tester, 'Sprawdź numer');
    expect(find.text('Numer zgadza się z zapisanym kontaktem.'), findsNothing);
    expect(find.text('Wpisz numer telefonu'), findsNothing);
    expect(
      tester.widget<BaseboundMascot>(find.byType(BaseboundMascot)).pose,
      DinoPose.celebrate,
    );
    expect(
      find.bySemanticsLabel('Numer zgadza się z zapisanym kontaktem.'),
      findsOneWidget,
    );
    final busyPlayback = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (call) async {
          audioCalls.add(call);
          if (call.method == 'initialize') return true;
          if (call.method == 'narrate' &&
              (call.arguments as Map)['sound'] == 'busy') {
            await busyPlayback.future;
          }
          return null;
        });
    await tapMissionAction(tester, 'Zadzwoń na niby', advanceFeedback: false);
    expect(
      find.text(
        'Linia jest zajęta. Nie udało się połączyć. Spróbuj wysłać krótki SMS.',
      ),
      findsOneWidget,
    );
    expect(lastMissionNarration(audioCalls)['sound'], 'busy');
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Wyślij SMS'), findsNothing);
    busyPlayback.complete();
    await tester.pumpAndSettle();
    expect(find.byType(PracticePhoneKeypad), findsNothing);
    await tapMissionAction(tester, 'Wyślij SMS');
    expect(find.text('Rozmowa na niby'), findsOneWidget);
    expect(find.text('Jestem z dala od okien.'), findsOneWidget);
    expect(
      find.text('Dobrze. Zostań tam i czekaj na odwołanie alarmu.'),
      findsOneWidget,
    );
    expect(find.text('Tylko ćwiczenie. Nic nie wysłano.'), findsOneWidget);
    expect(find.text('Posłuchaj odpowiedzi'), findsNothing);
    await tapMissionAction(tester, 'Zostań tutaj');
    await tapMissionAction(tester, 'Zostań tutaj');
    final characterBefore = tester.widget<AnimatedPositioned>(
      find.byKey(const ValueKey('mission-character')),
    );
    await tapMissionAction(tester, 'Wyjdź teraz');
    expect(find.textContaining('Zostań w domu.'), findsOneWidget);
    expect(find.byType(BaseboundMascot), findsNothing);
    expect(
      lastMissionNarration(audioCalls)['text'],
      contains('Zostań w domu.'),
    );
    final door = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Wyjdź teraz',
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
    await tapMissionAction(tester, 'Zostań i czekaj', advanceFeedback: false);
    expect(
      find.text('Dobrze. Zostań w domu. Czekaj na odwołanie alarmu.'),
      findsOneWidget,
    );
    expect(tester.widget<InkWell>(doorTapTarget).onTap, isNull);
    await finishMissionFeedback(tester);
    await tapMissionAction(tester, 'Zapamiętaj kroki');
    expect(find.byType(MissionScene), findsNothing);
    expect(find.text('Czekaj na odwołanie alarmu'), findsOneWidget);
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
    await tapMissionAction(tester, 'Zakończ ćwiczenie');
    expect(find.text('Ćwiczenie ukończone'), findsNothing);
    expect(find.text('Czekaj na odwołanie alarmu'), findsOneWidget);
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
    await tapMissionAction(tester, 'Ćwicz ponownie');
    expect(find.text('Alarm w domu'), findsOneWidget);
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
    await tapMissionAction(tester, 'Wybierz, dokąd pójdziesz');
    await tapMissionAction(tester, 'Dom: daleko', advanceFeedback: false);
    expect(lastMissionNarration(audioCalls)['sound'], 'select');
    await finishMissionFeedback(tester);
    expect(find.text('Nadal na zewnątrz'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['text'], contains('w stronę domu'));
    expect(lastMissionNarration(audioCalls)['sound'], 'noise');
    await tapMissionAction(tester, 'Wybierz, co zrobisz');
    expect(find.text('Co zrobisz?'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['sound'], isNull);
    final scene = find.byType(MissionScene);
    await tester.ensureVisible(scene);
    await tester.drag(scene, const Offset(0, 90));
    await tester.pumpAndSettle();
    expect(find.text('Jesteś nisko. Teraz chroń głowę.'), findsOneWidget);
    expect(lastMissionNarration(audioCalls)['sound'], 'action');
    await finishMissionFeedback(tester);
    await tapMissionAction(tester, 'Osłoń głowę', advanceFeedback: false);
    expect(lastMissionNarration(audioCalls)['sound'], 'action');
    await finishMissionFeedback(tester);
    expect(find.text('Dorosły pomaga ci'), findsOneWidget);
    await tapMissionAction(tester, 'Idź za dorosłym');
    expect(find.text('W schronieniu na niby'), findsOneWidget);
    await tapMissionAction(tester, 'Powiedz zaufanej osobie dorosłej');
    expect(find.text('Powiedz zaufanej osobie dorosłej'), findsOneWidget);
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
        'Znajdź miejsce',
        'Przejdź w głąb domu',
        'Wewnętrzny korytarz',
        'Mama',
        'Spróbuj zadzwonić raz',
      ]) {
        await tapMissionAction(tester, label);
      }
      expect(find.text('Wczytaj ponownie'), findsOneWidget);
      expect(find.byType(PracticePhoneKeypad), findsNothing);
      repository.failRead = false;
      await tapMissionAction(tester, 'Wczytaj ponownie');
      expect(find.byType(PracticePhoneKeypad), findsOneWidget);
      expect(
        find.text(
          'Nie zapisano jeszcze numeru telefonu. '
          'Poproś dorosłego o dodanie numeru w ustawieniach rodziny.',
        ),
        findsOneWidget,
      );
      await tapMissionAction(tester, 'Ćwicz dalej bez numeru');
      await tapMissionAction(tester, 'Wyślij SMS');
      expect(find.text('Rozmowa na niby'), findsOneWidget);
      await tapMissionAction(tester, 'Zostań tutaj');
      expect(find.text('Słyszysz głośny huk'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
