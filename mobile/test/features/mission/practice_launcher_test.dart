import 'package:do_bazy/features/mission/mission_scene.dart';
import 'package:do_bazy/features/mission/mission_screen.dart';
import 'package:do_bazy/features/mission/practice_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    '7+ launcher opens home mission directly and returns to practice',
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
      expect(find.text('Choose practice'), findsOneWidget);
      await _tap(tester, 'Alarm practice');
      expect(find.text('Where shall we practice?'), findsOneWidget);
      expect(find.text('At home'), findsOneWidget);
      expect(find.text('Outside'), findsOneWidget);
      await _tap(tester, 'At home');
      expect(find.byType(MissionScreen), findsOneWidget);
      expect(find.text('An alarm at home'), findsOneWidget);
      await _tap(tester, 'Find a place');
      expect(
        tester.widget<MissionScene>(find.byType(MissionScene)).choices,
        hasLength(3),
      );
      for (final label in [
        'Go to the window',
        'Go outside',
        'Move deeper inside',
      ]) {
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.label == label,
          ),
          findsOneWidget,
        );
      }

      await tester.tap(find.byTooltip('Leave practice'));
      await tester.pumpAndSettle();
      expect(find.byType(MissionScreen), findsNothing);
      expect(find.text('Choose practice'), findsOneWidget);
      expect(find.text('Alarm practice'), findsOneWidget);
      expect(find.text('Our map'), findsOneWidget);
      expect(find.text('Landmark practice'), findsNothing);
      expect(find.text('Map practice'), findsNothing);
      expect(audioCalls.where((call) => call.method == 'dispose').length, 2);
      expect(audioCalls.last.method, 'narrate');
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
