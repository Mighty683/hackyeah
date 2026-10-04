import 'package:do_bazy/features/parent/child_editor_screen.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:do_bazy/features/parent/data/family_plan_repository.dart';
import 'package:do_bazy/features/parent/parent_screen.dart';
import 'package:do_bazy/features/parent/practice_meeting_point_editor_screen.dart';
import 'package:do_bazy/features/parent/safe_point_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('optional setup reaches completion and can go back or review', (
    tester,
  ) async {
    await _start(tester, const ParentScreen());
    expect(find.text('Przygotuj plan rodziny'), findsOneWidget);
    await _tap(tester, 'Pomiń dane dziecka');
    expect(find.text('Z kim dziecko może się skontaktować?'), findsOneWidget);
    await _tap(tester, 'Pomiń kontakty');
    expect(find.text('Wybierz bezpieczne miejsca dziecka'), findsOneWidget);
    await _tap(tester, 'Pomiń bezpieczne miejsca');
    expect(find.text('Gotowi do wspólnych ćwiczeń'), findsOneWidget);
    expect(find.text('Ćwiczcie razem'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Wybierz bezpieczne miejsca dziecka'), findsOneWidget);
    await _tap(tester, 'Pomiń bezpieczne miejsca');
    await _tap(tester, 'Sprawdź ustawienia');
    expect(find.text('Przygotuj plan rodziny'), findsOneWidget);
    expect((await FamilyPlanRepository().load()).contacts, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('child fields stay separate and Back retains edits before save', (
    tester,
  ) async {
    await FamilyPlanRepository().save(
      const FamilyPlan(
        practiceMeetingPoint: PracticeMeetingPoint(
          presetId: 'fountain',
          label: 'Demo fountain',
        ),
      ),
    );
    await _start(tester, const ParentScreen());
    await _tap(tester, 'Dodaj dane dziecka');
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Krok 1 z 4'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo child');
    await _tap(tester, "Dodaj wiek dziecka");
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Krok 2 z 4'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '9');
    await tester.tap(find.byTooltip('Wstecz'));
    await tester.pumpAndSettle();
    expect(_fieldText(tester), 'Demo child');
    await _tap(tester, "Dodaj wiek dziecka");
    expect(_fieldText(tester), '9');
    await _tap(tester, 'Dodaj adres domu');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Fictional home');
    await _tap(tester, 'Dodaj potrzeby wsparcia');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo support note');
    await _tap(tester, 'Zapisz dane dziecka');

    expect(find.byType(ChildEditorScreen), findsNothing);
    expect(find.text('Z kim dziecko może się skontaktować?'), findsOneWidget);
    final child = (await FamilyPlanRepository().load()).child;
    expect(child.fullName, 'Demo child');
    expect(child.age, 9);
    expect(child.address, 'Fictional home');
    expect(child.supportNotes, 'Demo support note');
    expect(
      (await FamilyPlanRepository().load()).practiceMeetingPoint!.label,
      'Demo fountain',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('third contact saves and stops offering additional contacts', (
    tester,
  ) async {
    await FamilyPlanRepository().save(
      const FamilyPlan(
        contacts: [
          TrustedContact(name: 'Demo adult one'),
          TrustedContact(name: 'Demo adult two'),
        ],
        practiceMeetingPoint: PracticeMeetingPoint(
          presetId: 'fountain',
          label: 'Demo fountain',
        ),
      ),
    );
    await _start(tester, const ParentScreen());
    await _tap(tester, 'Pomiń dane dziecka');
    await _tap(tester, 'Dodaj zaufany kontakt');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo adult three');
    await _tap(tester, 'Dodaj numer telefonu');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '000000000');
    await _tap(tester, 'Dodaj relację');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo parent');
    await _tap(tester, 'Zapisz zaufany kontakt');

    expect(find.text('Demo adult three'), findsOneWidget);
    expect(find.text('Dodaj zaufany kontakt'), findsNothing);
    expect(find.text('Wybierz bezpieczne miejsca'), findsOneWidget);
    final contacts = (await FamilyPlanRepository().load()).contacts;
    expect(contacts.length, FamilyPlan.maxContacts);
    expect(contacts.last.phone, '000000000');
    expect(contacts.last.relationship, 'Demo parent');
    expect(
      (await FamilyPlanRepository().load()).practiceMeetingPoint!.label,
      'Demo fountain',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'safe place advances without a name but needs a retained map pin',
    (tester) async {
      SafePoint? saved;
      await _start(
        tester,
        _EditorLauncher(
          editor: SafePointEditorScreen(
            otherPoints: const [],
            onSave: (point) async => saved = point,
          ),
        ),
      );
      await _tap(tester, 'Open editor');
      expect(find.byType(TextField), findsOneWidget);
      await _tap(tester, '🏠 Dom');
      await _tap(tester, 'Wybierz pozycję na mapie', settle: false);
      await _pumpMap(tester);
      expect(find.byType(TextField), findsNothing);
      expect(
        _saveButton(tester, 'Zapisz bezpieczne miejsce').onPressed,
        isNull,
      );
      await _tap(tester, 'Użyj środka areny', settle: false);
      await tester.pump();
      expect(
        _saveButton(tester, 'Zapisz bezpieczne miejsce').onPressed,
        isNotNull,
      );
      final centreLocation = _locationValue(tester);
      await tester.ensureVisible(find.byTooltip('Przesuń znacznik na północ'));
      await tester.tap(find.byTooltip('Przesuń znacznik na północ'));
      await tester.pump();
      final retainedLocation = _locationValue(tester);
      expect(retainedLocation, isNot(centreLocation));
      await tester.tap(find.byTooltip('Wstecz'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Demo meeting place');
      await _tap(tester, 'Wybierz pozycję na mapie', settle: false);
      await _pumpMap(tester);
      expect(
        _saveButton(tester, 'Zapisz bezpieczne miejsce').onPressed,
        isNotNull,
      );
      expect(
        find.text('Pozycja wybrana. Możesz przesunąć znacznik.'),
        findsOneWidget,
      );
      expect(_locationValue(tester), retainedLocation);
      await _tap(tester, 'Zapisz bezpieczne miejsce', settle: false);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(SafePointEditorScreen), findsNothing);
      expect(saved, isNotNull);
      expect(saved!.name, 'Demo meeting place');
      expect(saved!.icon, '🏠');
      expect(SafePoint.fromJson(saved!.toJson()).icon, '🏠');
      final legacyPoint = saved!.toJson()..remove('icon');
      expect(SafePoint.fromJson(legacyPoint).icon, '📍');
      expect(saved!.latitude, inInclusiveRange(50, 51));
      expect(saved!.longitude, inInclusiveRange(19, 21));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('save failure keeps the editor and values available for retry', (
    tester,
  ) async {
    var failSave = true;
    ChildProfile? saved;
    await _start(
      tester,
      _EditorLauncher(
        editor: ChildEditorScreen(
          child: const ChildProfile(),
          onSave: (child) async {
            if (failSave) throw StateError('Storage unavailable');
            saved = child;
          },
        ),
      ),
    );
    await _tap(tester, 'Open editor');
    await tester.enterText(find.byType(TextField), 'Retained demo name');
    await _tap(tester, "Dodaj wiek dziecka");
    await _tap(tester, 'Dodaj adres domu');
    await _tap(tester, 'Dodaj potrzeby wsparcia');
    await tester.enterText(find.byType(TextField), 'Retained demo note');
    await _tap(tester, 'Zapisz dane dziecka');
    expect(find.byType(ChildEditorScreen), findsOneWidget);
    expect(_fieldText(tester), 'Retained demo note');
    expect(
      find.text(
        'Nie udało się zapisać. Twoje zmiany zostały zachowane. Spróbuj ponownie.',
      ),
      findsOneWidget,
    );
    expect(saved, isNull);

    failSave = false;
    await _tap(tester, 'Zapisz dane dziecka');
    expect(find.byType(ChildEditorScreen), findsNothing);
    expect(saved!.fullName, 'Retained demo name');
    expect(saved!.supportNotes, 'Retained demo note');
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice landmark saves and clears without replacing map pins', (
    tester,
  ) async {
    await FamilyPlanRepository().save(
      const FamilyPlan(
        contacts: [TrustedContact(name: 'Demo adult')],
        safePoints: [SafePoint(name: 'Demo pin', latitude: 50, longitude: 20)],
      ),
    );
    await _start(tester, const ParentScreen());
    await _tap(tester, 'Pomiń dane dziecka');
    await _tap(tester, 'Wybierz bezpieczne miejsca');
    await _tap(tester, 'Dodaj punkt spotkania do ćwiczeń');
    await _tap(tester, 'Użyj przykładowego obrazka');
    await _tap(tester, 'Punkt informacji');
    await tester.enterText(find.byType(TextField), 'Demo help desk');
    await _tap(tester, 'Zapisz punkt spotkania do ćwiczeń');

    var plan = await FamilyPlanRepository().load();
    expect(plan.practiceMeetingPoint!.presetId, 'information_desk');
    expect(plan.practiceMeetingPoint!.label, 'Demo help desk');
    expect(plan.safePoints.single.name, 'Demo pin');
    expect(plan.contacts.single.name, 'Demo adult');
    final delete = find.byTooltip('Usuń Demo help desk');
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await _tap(tester, 'Usuń');
    plan = await FamilyPlanRepository().load();
    expect(plan.practiceMeetingPoint, isNull);
    expect(plan.safePoints.single.name, 'Demo pin');
    expect(plan.contacts.single.name, 'Demo adult');
    expect(tester.takeException(), isNull);
  });

  testWidgets('practice landmark error retains selection and label for retry', (
    tester,
  ) async {
    var failSave = true;
    PracticeMeetingPoint? saved;
    await _start(
      tester,
      _EditorLauncher(
        editor: PracticeMeetingPointEditorScreen(
          point: const PracticeMeetingPoint(
            presetId: 'removed-preset',
            label: 'Old custom label',
          ),
          onSave: (point) async {
            if (failSave) throw StateError('Storage unavailable');
            saved = point;
          },
        ),
      ),
    );
    await _tap(tester, 'Open editor');
    expect(
      find.textContaining('Zapisany obrazek jest niedostępny.'),
      findsOneWidget,
    );
    await _tap(tester, 'Punkt informacji');
    expect(_fieldText(tester), 'Old custom label');
    await tester.enterText(find.byType(TextField), 'Retained meeting label');
    await _tap(tester, 'Zapisz punkt spotkania do ćwiczeń');
    expect(saved, isNull);
    expect(_fieldText(tester), 'Retained meeting label');
    expect(
      find.text(
        'Nie udało się zapisać. Twoje zmiany zostały zachowane. Spróbuj ponownie.',
      ),
      findsOneWidget,
    );
    failSave = false;
    await _tap(tester, 'Zapisz punkt spotkania do ćwiczeń');
    expect(saved!.presetId, 'information_desk');
    expect(saved!.label, 'Retained meeting label');
    expect(tester.takeException(), isNull);
  });
}

Future<void> _start(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: home));
  await tester.pumpAndSettle();
}

Future<void> _tap(
  WidgetTester tester,
  String label, {
  bool settle = true,
}) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

String _locationValue(WidgetTester tester) => tester
    .widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Pozycja bezpiecznego miejsca',
      ),
    )
    .properties
    .value!;

FilledButton _saveButton(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((widget) => widget is FilledButton),
      ),
    );

// Flame renders continuously; bounded pumps let the offline map load.
Future<void> _pumpMap(WidgetTester tester) async {
  for (var frame = 0; frame < 5; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _EditorLauncher extends StatelessWidget {
  const _EditorLauncher({required this.editor});

  final Widget editor;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () =>
            Navigator.of(context)
                .push<bool>(MaterialPageRoute<bool>(builder: (_) => editor)),
        child: const Text('Open editor'),
      ),
    ),
  );
}
