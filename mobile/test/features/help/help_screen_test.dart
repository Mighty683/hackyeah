import 'package:do_bazy/features/help/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('every help scenario opens the preview and returns to choices', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HelpScreen()));
    for (final label in [
      'Ktoś nie reaguje',
      'Słyszysz syrenę',
      'Nie wiem, gdzie jestem',
      'Nie wiem',
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.text('Interaktywny przewodnik'), findsOneWidget);
      expect(
        find.textContaining(
          'Tutaj pojawi się interaktywny przewodnik dla dzieci.',
        ),
        findsOneWidget,
      );
      expect(find.text('Co się dzieje?'), findsNothing);
      expect(find.text('Przećwicz telefon pod 112'), findsNothing);
      await tester.tap(find.text('Wróć do wyboru scenariusza'));
      await tester.pumpAndSettle();
      expect(find.text('Co się dzieje?'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('back returns from preview, then closes help to its opener', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openHelpScreen(context),
              child: const Text('Open help'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open help'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nie wiem'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Co się dzieje?'), findsOneWidget);
    await tester.tap(find.byTooltip('Zamknij pomoc'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpScreen), findsNothing);
    expect(find.text('Open help'), findsOneWidget);
  });
}
