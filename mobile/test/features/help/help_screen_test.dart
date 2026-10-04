import 'dart:async';

import 'package:do_bazy/features/help/help_context.dart';
import 'package:do_bazy/features/help/help_phone.dart';
import 'package:do_bazy/features/help/help_screen.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game/fake_location_source.dart';

class FakeHelpPhone extends HelpPhone {
  final updates = StreamController<HelpPhoneService>.broadcast();
  final opened = <String>[];
  List<TrustedContact> contacts = const [];

  @override
  Stream<HelpPhoneService> serviceStates() => updates.stream;

  @override
  Future<List<TrustedContact>> loadContacts() async => contacts;

  @override
  Future<bool> openDialler(String phone) async {
    opened.add(phone);
    return true;
  }
}

void main() {
  late FakeHelpPhone phone;
  late FakeLocationSource location;

  setUp(() {
    phone = FakeHelpPhone();
    location = FakeLocationSource();
  });

  tearDown(() async {
    await phone.updates.close();
    await location.updates.close();
  });

  Future<void> open(
    WidgetTester tester, {
    List<SafePoint> places = const [],
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HelpScreen(
          phone: phone,
          helpContext: HelpContext(
            source: location,
            loadPlan: () async => FamilyPlan(safePoints: places),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> service(WidgetTester tester, HelpPhoneService state) async {
    phone.updates.add(state);
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(location.updates.hasListener, isFalse);
    expect(phone.updates.hasListener, isFalse);
  }

  testWidgets(
    'situation first and helper returns to the selected instruction',
    (tester) async {
      await open(tester);
      expect(find.text('Co się dzieje?'), findsOneWidget);
      await tap(tester, 'Nie wiem, gdzie jestem');
      await tap(tester, 'Zaufana osoba dorosła jest tutaj');
      expect(
        find.text('Powiedz tej osobie dorosłej, co się stało.'),
        findsOneWidget,
      );
      expect(find.text('Przećwicz telefon pod 112'), findsNothing);
      await tap(tester, 'Ta osoba nie może pomóc');
      expect(
        find.text('Zostań tutaj, chyba że jest niebezpiecznie.'),
        findsOneWidget,
      );
      expect(phone.opened, isEmpty);
      await close(tester);
    },
  );

  testWidgets('urgent practice works offline and only opens after a tap', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'Ktoś nie reaguje');
    for (final state in HelpPhoneService.values) {
      await service(tester, state);
      expect(find.text('Przećwicz telefon pod 112'), findsOneWidget);
      expect(find.text('Przećwicz następny krok'), findsOneWidget);
    }
    expect(phone.opened, isEmpty);
    await tap(tester, 'Przećwicz telefon pod 112');
    expect(phone.opened, ['112']);
    await tap(tester, 'Przećwicz następny krok');
    expect(
      find.text('Wykonuj polecenia operatora numeru alarmowego.'),
      findsOneWidget,
    );
    await close(tester);
  });

  testWidgets('shelter route failures and unavailable adults have a fallback', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'Alarm lotniczy');
    await tap(tester, 'W budynku');
    await tap(tester, 'Przeczytaj krok o schronieniu');
    await tap(tester, 'Nie znam drogi');
    expect(find.text('Stosuj się do oficjalnych poleceń.'), findsOneWidget);
    await tap(tester, 'Wybierz moją pozycję ponownie');
    await tap(tester, 'Na zewnątrz, nie słychać wybuchów');
    await tap(tester, 'Nie mogę dotrzeć do schronienia');
    expect(find.text('Stosuj się do oficjalnych poleceń.'), findsOneWidget);
    await tap(tester, 'Wybierz moją pozycję ponownie');
    await tap(tester, 'Nie wiem');
    await tap(tester, 'Żaden dorosły nie może pomóc');
    expect(find.text('Stosuj się do oficjalnych poleceń.'), findsOneWidget);
    await close(tester);
  });

  testWidgets(
    'lost practice stays offline while real contact actions require service',
    (tester) async {
      phone.contacts = const [
        TrustedContact(name: 'Demo adult', phone: '+48123456789'),
      ];
      await open(tester);
      await tap(tester, 'Nie wiem, gdzie jestem');
      expect(
        find.text('Zostań tutaj, chyba że jest niebezpiecznie.'),
        findsOneWidget,
      );
      expect(
        find.text('Otwórz telefon, aby zadzwonić do dorosłego'),
        findsNothing,
      );
      expect(find.text('Przećwicz telefon pod 112'), findsOneWidget);
      await service(tester, HelpPhoneService.available);
      expect(
        find.text('Otwórz telefon, aby zadzwonić do dorosłego'),
        findsOneWidget,
      );
      expect(find.text('Przećwicz telefon pod 112'), findsOneWidget);
      await service(tester, HelpPhoneService.emergencyOnly);
      expect(
        find.text('Otwórz telefon, aby zadzwonić do dorosłego'),
        findsNothing,
      );
      expect(find.text('Przećwicz telefon pod 112'), findsOneWidget);
      await tap(tester, 'Zaufana osoba dorosła jest tutaj');
      expect(
        find.text('Powiedz tej osobie dorosłej, co się stało.'),
        findsOneWidget,
      );
      expect(find.text('Przećwicz telefon pod 112'), findsNothing);
      expect(phone.opened, isEmpty);
      await close(tester);
    },
  );

  testWidgets(
    'nearby place never chooses a situation or skips inside/outside',
    (tester) async {
      await open(
        tester,
        places: const [
          SafePoint(name: 'Dom', latitude: 50.005, longitude: 20.001),
        ],
      );
      location.updates.add(fix(DateTime.now()));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Możesz być blisko miejsca: Dom'),
        findsOneWidget,
      );
      expect(find.text('Co się dzieje?'), findsOneWidget);
      await service(tester, HelpPhoneService.available);
      await tap(tester, 'Alarm lotniczy');
      expect(find.text('W budynku'), findsOneWidget);
      expect(find.text('Na zewnątrz, nie słychać wybuchów'), findsOneWidget);
      expect(find.text('Przećwicz telefon pod 112'), findsNothing);
      await close(tester);
    },
  );

  testWidgets(
    'backgrounding clears service and GPS until fresh updates arrive',
    (tester) async {
      await open(tester);
      await service(tester, HelpPhoneService.available);
      await tap(tester, 'Nie wiem');
      expect(find.text('Przećwicz telefon pod 112'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(phone.updates.hasListener, isFalse);
      expect(location.updates.hasListener, isFalse);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(phone.updates.hasListener, isTrue);
      expect(find.text('Przećwicz telefon pod 112'), findsOneWidget);
      await service(tester, HelpPhoneService.available);
      expect(find.text('Przećwicz telefon pod 112'), findsOneWidget);
      expect(location.requests, 0);
      await close(tester);
    },
  );
}
