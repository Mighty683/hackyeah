import 'dart:async';

import 'package:do_bazy/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startup error can retry and still opens the help prototype', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      BaseboundApp(
        initialize: () async {
          if (++attempts == 1) throw StateError('Storage unavailable');
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nie udało się przygotować ćwiczenia.'), findsOneWidget);
    await tester.tap(find.text('Potrzebuję pomocy'));
    await tester.pumpAndSettle();
    expect(find.text('Nie udało się przygotować ćwiczenia.'), findsNothing);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spróbuj ponownie'));
    await tester.pumpAndSettle();
    expect(find.text('Witaj w Tuptu'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('help is hidden while setup is loading and on welcome', (
    tester,
  ) async {
    final ready = Completer<void>();
    await tester.pumpWidget(BaseboundApp(initialize: () => ready.future));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Potrzebuję pomocy'), findsNothing);
    ready.complete();
    await tester.pumpAndSettle();
    expect(find.text('Witaj w Tuptu'), findsOneWidget);
    expect(find.text('Potrzebuję pomocy'), findsNothing);
  });
}
