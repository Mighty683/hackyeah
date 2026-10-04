import 'package:do_bazy/app.dart';
import 'package:do_bazy/features/game/game_screen.dart';
import 'package:do_bazy/features/landmarks/data/landmark_repository.dart';
import 'package:do_bazy/features/landmarks/widgets/landmark_photo.dart';
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
      expect(plan.child.age, 9);
      expect(plan.contacts, hasLength(3));
      expect(await LandmarkRepository().load(), hasLength(3));
      await _child(tester);
      await _tap(tester, 'Ćwiczenia');
      await _tap(tester, 'Ćwiczenie alarmu');
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
    'seeded photos open in lost practice and shared map',
    (tester) async {
      await _start(tester);
      await _child(tester);
      await _tap(tester, 'Ćwiczenia');
      await _tap(tester, "Ćwiczenie zgubienia się");
      await _wait(
        tester,
        find.text('Punkt spotkania do ćwiczeń: Czerwony sklep na rogu'),
      );
      expect(find.byType(LandmarkPhoto), findsWidgets);
      await _tap(tester, 'Punkt spotkania w pobliżu');
      await _wait(tester, find.byType(LostMissionScreen));
      final mission = tester.widget<LostMissionScreen>(
        find.byType(LostMissionScreen),
      );
      expect(mission.practiceContext.photoMeetingPoint, isNotNull);
      await tester.tap(find.byTooltip('Opuść ćwiczenie'));
      await _wait(tester, find.text('Wybierz scenariusz'));
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
        '11',
      );
      await _tap(tester, 'Zresetuj demo');
      await _wait(tester, find.text('Witaj w Tuptu'));
      expect(
        (await repository.load()).child.fullName,
        'Aleks Przykładowy (demo)',
      );
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
    'help emergency and trusted contact calls remain pretend',
    (tester) async {
      await _start(tester);
      await _tap(tester, 'Potrzebuję pomocy');
      await _tap(tester, 'Ktoś nie reaguje');
      await _wait(tester, find.text('Przećwicz telefon pod 112'));
      await _tap(tester, 'Przećwicz telefon pod 112');
      await _wait(tester, find.byType(AlertDialog));
      expect(find.textContaining('prawdziwego połączenia'), findsWidgets);
      await _closeDialog(tester);
      await tester.tap(find.byTooltip('Poprzedni krok'));
      await _wait(tester, find.text('Co się dzieje?'));
      await _tap(tester, 'Nie wiem, gdzie jestem');
      for (final contact in ['Mama (demo)', 'Tata (demo)', 'Babcia (demo)']) {
        await _tap(tester, 'Otwórz telefon, aby zadzwonić do dorosłego');
        await _wait(tester, find.text('Otwórz telefon, aby zadzwonić do…'));
        await _tap(tester, contact);
        await _wait(tester, find.byType(AlertDialog));
        expect(find.textContaining('prawdziwego połączenia'), findsWidgets);
        await _closeDialog(tester);
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
    '9',
  );
  await _tap(tester, 'Podaj imię');
  expect(
    tester
        .widget<TextField>(find.byKey(const ValueKey('child-name')))
        .controller!
        .text,
    'Aleks Przykładowy (demo)',
  );
  await _tap(tester, 'Wybierz postać');
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

Future<void> _closeDialog(WidgetTester tester) async {
  final dialog = find.byType(AlertDialog);
  final button = find.descendant(of: dialog, matching: find.byType(TextButton));
  await tester.tap(button.last);
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}
