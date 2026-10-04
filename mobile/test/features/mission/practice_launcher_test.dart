import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/mission_screen.dart';
import 'package:do_bazy/features/mission/practice_launcher.dart';
import 'package:do_bazy/ui/basebound_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      expect(find.text('Ćwiczenie alarmu'), findsNothing);
      expect(find.text("Ćwiczenie zgubienia się"), findsNothing);
      await _tap(tester, 'Ćwiczenia');
      expect(find.byType(PracticeScenarioScreen), findsOneWidget);
      expect(find.text('Wybierz scenariusz'), findsOneWidget);
      expect(find.byType(BaseboundActionTile), findsNWidgets(2));
      expect(find.text('Nasza mapa'), findsNothing);
      await _tap(tester, 'Ćwiczenie alarmu');
      expect(find.text('Gdzie ćwiczymy?'), findsOneWidget);
      expect(find.text('W domu'), findsOneWidget);
      expect(find.text('Na zewnątrz'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Wybierz scenariusz'), findsOneWidget);
      expect(find.text('Ćwiczenie alarmu'), findsOneWidget);
      await _tap(tester, 'Ćwiczenie alarmu');
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
      expect(find.text('Ćwiczenie alarmu'), findsOneWidget);
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
