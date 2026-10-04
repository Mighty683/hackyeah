import 'package:do_bazy/app.dart';
import 'package:do_bazy/features/game/game_screen.dart';
import 'package:do_bazy/features/landmarks/data/landmark_repository.dart';
import 'package:do_bazy/features/mission/lost_mission_screen.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/platform/demo_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/browser_assets.dart';

// These exercise the default browser adapters, not injected plugin stand-ins.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    DemoSession.instance.reset();
    installBrowserAssetLoader();
  });
  tearDown(() {
    removeBrowserAssetLoader();
    DemoSession.instance.reset();
  });

  testWidgets(
    'default browser startup and child alarm decision work',
    (tester) async {
      await _start(tester);
      final plan = await FamilyPlanRepository().load();
      expect(plan.child.toJson(), const ChildProfile().toJson());
      expect(plan.contacts, hasLength(3));
      expect(await LandmarkRepository().load(), hasLength(3));
      await _child(tester);
      await _tap(tester, 'Ćwiczenia');
      await _tap(tester, 'Słyszysz alarm');
      await _tap(tester, 'W domu');
      await _wait(tester, find.text('Alarm w domu'));
      await _tap(tester, 'Znajdź miejsce');
      await _tap(tester, 'Podejdź do okna');
      expect(
        find.text('Przy oknach jest mniej bezpiecznie. Odsuń się od nich.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Opuść ćwiczenie'));
      await _wait(tester, find.text('Wybierz scenariusz'));
      final error = tester.takeException();
      expect(error, isNull);
      await _dispose(tester);
    },
    skip: !kIsWeb,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    'unfinished lost practice stays disabled while shared map remains available',
    (tester) async {
      await _start(tester);
      await _child(tester);
      await _tap(tester, 'Ćwiczenia');
      const unavailableNotice =
          'Ten scenariusz nie jest jeszcze gotowy. '
          'Scenariusz „Słyszysz alarm” jest gotowy do testów.';
      await tester.tap(find.byTooltip(unavailableNotice));
      await _wait(tester, find.text(unavailableNotice));
      expect(find.byType(LostMissionScreen), findsNothing);
      expect(find.text('Wybierz scenariusz'), findsOneWidget);
      await _tap(tester, 'Słyszysz alarm');
      await _wait(tester, find.text('Gdzie ćwiczymy?'));
      await _tap(tester, 'Zresetuj demo');
      await _wait(tester, find.text('Witaj w Tuptu'));
      await _child(tester);
      await _tap(tester, 'Nasza mapa');
      await _wait(tester, find.byType(GameScreen));
      // Flame deliberately continues producing frames; settling is not completion.
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Nasza mapa'), findsWidgets);
      final demoPosition = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Fikcyjna pozycja demo · bez GPS',
      );
      await _wait(tester, demoPosition);
      expect(demoPosition, findsOneWidget);
      final error = tester.takeException();
      expect(error, isNull);
      await _dispose(tester);
    },
    skip: !kIsWeb,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    'reset discards edits and returns from child setup to welcome',
    (tester) async {
      await _start(tester);
      final repository = FamilyPlanRepository();
      final plan = await repository.load();
      await repository.save(
        plan.copyWith(
          child: const ChildProfile(fullName: 'Edited demo', age: 11),
        ),
      );
      await _tap(tester, "Jestem dzieckiem");
      await _wait(tester, find.byKey(const ValueKey('child-age')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('child-age')))
            .controller!
            .text,
        '',
      );
      await _tap(tester, 'Zresetuj demo');
      await _wait(tester, find.text('Witaj w Tuptu'));
      expect((await repository.load()).child.fullName, '');
      expect(await LandmarkRepository().load(), hasLength(3));
      expect(find.byKey(const ValueKey('child-age')), findsNothing);
      final error = tester.takeException();
      expect(error, isNull);
      await _dispose(tester);
    },
    skip: !kIsWeb,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    'help choices show the planned interactive guide',
    (tester) async {
      await _start(tester);
      await _tap(tester, 'Potrzebuję pomocy');
      for (final label in [
        'Ktoś nie reaguje',
        'Słyszysz syrenę',
        'Nie wiem, gdzie jestem',
        'Nie wiem',
      ]) {
        await _tap(tester, label);
        await _wait(tester, find.text('Interaktywny przewodnik'));
        expect(find.byType(AlertDialog), findsNothing);
        await _tap(tester, 'Wróć do wyboru scenariusza');
        await _wait(tester, find.text('Co się dzieje?'));
      }
      final error = tester.takeException();
      expect(error, isNull);
      await _dispose(tester);
    },
    skip: !kIsWeb,
    timeout: const Timeout(Duration(seconds: 45)),
  );
}

Future<void> _start(WidgetTester tester) async {
  addTearDown(() => _dispose(tester));
  tester.view.physicalSize = const Size(430, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const BaseboundApp());
  await _wait(tester, find.text("Jestem dzieckiem"));
  // Welcome requests the mock permission in a post-frame callback.
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _child(WidgetTester tester) async {
  await _tap(tester, "Jestem dzieckiem");
  await _wait(tester, find.byKey(const ValueKey('child-age')));
  expect(
    tester
        .widget<TextField>(find.byKey(const ValueKey('child-age')))
        .controller!
        .text,
    '',
  );
  await tester.enterText(find.byKey(const ValueKey('child-age')), '9');
  await _tap(tester, 'Zatwierdź wiek');
  expect(
    tester
        .widget<TextField>(find.byKey(const ValueKey('child-name')))
        .controller!
        .text,
    '',
  );
  await tester.enterText(
    find.byKey(const ValueKey('child-name')),
    'Demo child',
  );
  await _tap(tester, 'Zatwierdź imię');
  await _tap(tester, 'Chłopiec');
  await _tap(tester, 'Rozpocznij ćwiczenie');
  await _wait(tester, find.text('Wybierz zajęcie'));
}

Future<void> _tap(WidgetTester tester, String label) async {
  final semantics = find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );
  final target = semantics.evaluate().isEmpty ? find.text(label) : semantics;
  await _wait(tester, target);
  await tester.ensureVisible(target.first);
  await tester.tap(target.first);
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _wait(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (target.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }
  }
  throw StateError(
    'Missing $target. Text: ${tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).join(' | ')}. Exception: ${tester.takeException()}',
  );
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}
