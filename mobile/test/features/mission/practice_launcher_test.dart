import 'dart:ui' show PointerDeviceKind;

import 'package:do_bazy/features/demo/web_demo_shell.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/widgets/basebound_mascot.dart';
import 'package:do_bazy/widgets/child_character.dart';
import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/mission_screen.dart';
import 'package:do_bazy/features/mission/practice_launcher.dart';
import 'package:do_bazy/ui/basebound_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phone activity menu keeps dino and controls without scrolling', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final fonts = FontLoader('Nunito')
        ..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'));
      await fonts.load();
    });
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 577);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const channel = MethodChannel('basebound/mission_audio');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => call.method == 'initialize' ? false : null,
        );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: BaseboundTheme.training(),
        home: WebDemoShell(
          onReset: () {},
          child: const PracticeLauncher(
            child: ChildProfile(fullName: 'Aleks Przykładowy'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BaseboundMascot), findsOneWidget);
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, 0);
    for (final label in ['Ćwiczenia', 'Nasza mapa', 'Potrzebuję pomocy']) {
      expect(find.text(label).hitTestable(), findsOneWidget);
    }
    expect(find.byTooltip('Posłuchaj ponownie').hitTestable(), findsOneWidget);
    final activities = find.byType(BaseboundActionTile);
    for (final tile in activities.evaluate()) {
      expect(
        tester.getSize(find.byWidget(tile.widget)).height,
        greaterThanOrEqualTo(80),
      );
    }
    expect(
      find.descendant(
        of: activities.first,
        matching: find.byType(ChildCharacter),
      ),
      findsOneWidget,
    );
    // Artwork and label are part of the same button, including its navigation.
    await tester.tap(find.byType(ChildCharacter));
    await tester.pumpAndSettle();
    expect(find.text('Wybierz scenariusz'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Brak głosu? Czytaj z dorosłym.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'activities open a scenario list and home mission returns to that list',
    (tester) async {
      const channel = MethodChannel('basebound/mission_audio');
      final audioCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            audioCalls.add(call);
            return call.method == 'initialize' ? true : null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      await tester.pumpWidget(const MaterialApp(home: PracticeLauncher()));
      await tester.pumpAndSettle();
      expect(find.text('Wybierz zajęcie'), findsOneWidget);
      expect(find.byType(BaseboundActionTile), findsNWidgets(2));
      expect(find.text('Ćwiczenia'), findsOneWidget);
      expect(find.text('Nasza mapa'), findsOneWidget);
      expect(find.text('Słyszysz alarm'), findsNothing);
      expect(find.text('Ćwicz z mapą'), findsNothing);
      await _tap(tester, 'Ćwiczenia');
      expect(find.byType(PracticeScenarioScreen), findsOneWidget);
      expect(find.text('Wybierz scenariusz'), findsOneWidget);
      expect(find.byType(BaseboundActionTile), findsNWidgets(2));
      expect(find.text('Nasza mapa'), findsNothing);
      const unavailableNotice =
          'Ten scenariusz nie jest jeszcze gotowy. '
          'Scenariusz „Słyszysz alarm” jest gotowy do testów.';
      final lostTile = tester
          .widgetList<BaseboundActionTile>(find.byType(BaseboundActionTile))
          .singleWhere((tile) => tile.label == 'Ćwicz z mapą');
      expect(lostTile.onPressed, isNull);
      final lostSemantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Ćwicz z mapą',
        ),
      );
      expect(lostSemantics.properties.enabled, isFalse);
      expect(lostSemantics.properties.onTap, isNull);
      expect(lostSemantics.properties.hint, unavailableNotice);
      expect(find.byTooltip(unavailableNotice), findsOneWidget);
      await tester.tap(find.byTooltip(unavailableNotice));
      await tester.pumpAndSettle();
      expect(find.text(unavailableNotice), findsOneWidget);
      expect(find.byType(PracticeScenarioScreen), findsOneWidget);
      expect(find.text('Wybierz scenę'), findsNothing);
      expect(
        (audioCalls.last.arguments as Map)['text'],
        contains('Słyszysz alarm jest gotowy do testów'),
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Ćwicz z mapą')));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text(unavailableNotice), findsOneWidget);
      await mouse.removePointer();
      await tester.pumpAndSettle();
      await _tap(tester, 'Słyszysz alarm');
      expect(find.text('Gdzie ćwiczymy?'), findsOneWidget);
      expect(find.text('W domu'), findsOneWidget);
      expect(find.text('Na zewnątrz'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Wybierz scenariusz'), findsOneWidget);
      expect(find.text('Słyszysz alarm'), findsOneWidget);
      await _tap(tester, 'Słyszysz alarm');
      await _tap(tester, 'W domu');
      expect(find.byType(MissionScreen), findsOneWidget);
      expect(find.text('Alarm w domu'), findsOneWidget);
      await _tap(tester, 'Znajdź miejsce');
      expect(
        tester.widget<MissionScene>(find.byType(MissionScene)).choices,
        hasLength(3),
      );
      for (final label in [
        'Podejdź do okna',
        'Wyjdź na zewnątrz',
        'Przejdź w głąb domu',
      ]) {
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.label == label,
          ),
          findsOneWidget,
        );
      }

      await tester.tap(find.byTooltip('Opuść ćwiczenie'));
      await tester.pumpAndSettle();
      expect(find.byType(MissionScreen), findsNothing);
      expect(find.text('Wybierz scenariusz'), findsOneWidget);
      expect(find.text('Słyszysz alarm'), findsOneWidget);
      expect(find.text('Nasza mapa'), findsNothing);
      expect(find.text('Landmark practice'), findsNothing);
      expect(find.text('Map practice'), findsNothing);
      expect(audioCalls.where((call) => call.method == 'dispose').length, 3);
      expect(audioCalls.last.method, 'narrate');
      expect(
        (audioCalls.last.arguments as Map)['text'],
        contains('Wybierz scenariusz'),
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(PracticeScenarioScreen), findsNothing);
      expect(find.text('Wybierz zajęcie'), findsOneWidget);
      expect(find.text('Ćwiczenia'), findsOneWidget);
      expect(find.text('Nasza mapa'), findsOneWidget);
      expect(
        (audioCalls.last.arguments as Map)['text'],
        contains('Wybierz zajęcie'),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
