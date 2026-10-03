import 'dart:async';

import 'package:do_bazy/app.dart';
import 'package:do_bazy/features/help/help_screen.dart';
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
    expect(find.text('Could not prepare practice.'), findsOneWidget);
    await tester.tap(find.text('I need help · prototype'));
    await tester.pumpAndSettle();
    expect(find.text('Could not prepare practice.'), findsNothing);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Safe Path'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('help remains accessible while setup is loading', (tester) async {
    final ready = Completer<void>();
    await tester.pumpWidget(BaseboundApp(initialize: () => ready.future));
    await tester.pump();
    await tester.tap(find.text('I need help · prototype'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HelpScreen), findsOneWidget);
    ready.complete();
    await tester.pumpAndSettle();
    expect(
      find.text('Welcome to Safe Path', skipOffstage: false),
      findsNothing,
    );
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Safe Path'), findsOneWidget);
  });
}
