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
    expect(find.text('Set up your family plan'), findsOneWidget);
    await _tap(tester, 'Skip child details');
    expect(find.text('Who can your child contact?'), findsOneWidget);
    await _tap(tester, 'Skip contacts');
    expect(find.text('Choose your child’s safe places'), findsOneWidget);
    await _tap(tester, 'Skip safe places');
    expect(find.text('Ready to practice together'), findsOneWidget);
    expect(find.text('Play together'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Choose your child’s safe places'), findsOneWidget);
    await _tap(tester, 'Skip safe places');
    await _tap(tester, 'Review setup');
    expect(find.text('Set up your family plan'), findsOneWidget);
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
    await _tap(tester, 'Add child details');
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo child');
    await _tap(tester, "Add child's age");
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '9');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(_fieldText(tester), 'Demo child');
    await _tap(tester, "Add child's age");
    expect(_fieldText(tester), '9');
    await _tap(tester, 'Add home address');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Fictional home');
    await _tap(tester, 'Add support needs');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo support note');
    await _tap(tester, 'Save child details');

    expect(find.byType(ChildEditorScreen), findsNothing);
    expect(find.text('Who can your child contact?'), findsOneWidget);
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
    await _tap(tester, 'Skip child details');
    await _tap(tester, 'Add a trusted contact');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo adult three');
    await _tap(tester, 'Add phone number');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '000000000');
    await _tap(tester, 'Add relationship');
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Demo parent');
    await _tap(tester, 'Save trusted contact');

    expect(find.text('Demo adult three'), findsOneWidget);
    expect(find.text('Add a trusted contact'), findsNothing);
    expect(find.text('Choose safe places'), findsOneWidget);
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
      await _tap(tester, 'Choose map location', settle: false);
      await _pumpMap(tester);
      expect(find.byType(TextField), findsNothing);
      expect(_saveButton(tester, 'Save safe place').onPressed, isNull);
      await _tap(tester, 'Use arena centre', settle: false);
      await tester.pump();
      expect(_saveButton(tester, 'Save safe place').onPressed, isNotNull);
      final centreLocation = _locationValue(tester);
      await tester.ensureVisible(find.byTooltip('Move pin north'));
      await tester.tap(find.byTooltip('Move pin north'));
      await tester.pump();
      final retainedLocation = _locationValue(tester);
      expect(retainedLocation, isNot(centreLocation));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Demo meeting place');
      await _tap(tester, 'Choose map location', settle: false);
      await _pumpMap(tester);
      expect(_saveButton(tester, 'Save safe place').onPressed, isNotNull);
      expect(
        find.text('Location selected. You can move the pin.'),
        findsOneWidget,
      );
      expect(_locationValue(tester), retainedLocation);
      await _tap(tester, 'Save safe place', settle: false);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(SafePointEditorScreen), findsNothing);
      expect(saved, isNotNull);
      expect(saved!.name, 'Demo meeting place');
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
    await _tap(tester, "Add child's age");
    await _tap(tester, 'Add home address');
    await _tap(tester, 'Add support needs');
    await tester.enterText(find.byType(TextField), 'Retained demo note');
    await _tap(tester, 'Save child details');
    expect(find.byType(ChildEditorScreen), findsOneWidget);
    expect(_fieldText(tester), 'Retained demo note');
    expect(
      find.text('Could not save. Your edits are still here. Try again.'),
      findsOneWidget,
    );
    expect(saved, isNull);

    failSave = false;
    await _tap(tester, 'Save child details');
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
    await _tap(tester, 'Skip child details');
    await _tap(tester, 'Choose safe places');
    await _tap(tester, 'Add a practice meeting point');
    await _tap(tester, 'Information desk');
    await _tap(tester, 'Name this meeting point');
    await tester.enterText(find.byType(TextField), 'Demo help desk');
    await _tap(tester, 'Save practice meeting point');

    var plan = await FamilyPlanRepository().load();
    expect(plan.practiceMeetingPoint!.presetId, 'information_desk');
    expect(plan.practiceMeetingPoint!.label, 'Demo help desk');
    expect(plan.safePoints.single.name, 'Demo pin');
    expect(plan.contacts.single.name, 'Demo adult');
    final delete = find.byTooltip('Delete Demo help desk');
    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    await _tap(tester, 'Delete');
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
      find.textContaining('The saved picture is unavailable.'),
      findsOneWidget,
    );
    await _tap(tester, 'Information desk');
    await _tap(tester, 'Name this meeting point');
    expect(_fieldText(tester), 'Old custom label');
    await tester.enterText(find.byType(TextField), 'Retained meeting label');
    await _tap(tester, 'Save practice meeting point');
    expect(saved, isNull);
    expect(_fieldText(tester), 'Retained meeting label');
    expect(
      find.text('Could not save. Your edits are still here. Try again.'),
      findsOneWidget,
    );
    failSave = false;
    await _tap(tester, 'Save practice meeting point');
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
            widget.properties.label == 'Safe place location',
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
