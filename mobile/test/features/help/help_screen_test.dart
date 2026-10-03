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

  testWidgets('helper check comes first and a nearby helper removes calling', (
    tester,
  ) async {
    await open(tester);
    await service(tester, HelpPhoneService.available);
    expect(find.text('Can someone nearby help you?'), findsOneWidget);
    expect(find.text('Call 112'), findsNothing);
    expect(find.text('What is happening?'), findsNothing);
    await tap(tester, 'Yes');
    expect(find.text('Tell that adult what happened.'), findsOneWidget);
    expect(find.text('Call 112'), findsNothing);
    expect(phone.opened, isEmpty);
    await close(tester);
  });

  testWidgets('alone urgent case follows live service and only calls on tap', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'No one can help');
    expect(find.text('Call 112'), findsNothing);
    await tap(tester, 'Someone is not responding');
    expect(find.text('Shout for an adult’s help.'), findsOneWidget);
    expect(find.text('Call 112 now'), findsNothing);
    await service(tester, HelpPhoneService.emergencyOnly);
    expect(find.text('Call 112 now'), findsOneWidget);
    expect(phone.opened, isEmpty);
    await tap(tester, 'Call 112 now');
    expect(phone.opened, ['112']);
    await service(tester, HelpPhoneService.unavailable);
    expect(find.text('Call 112 now'), findsNothing);
    expect(find.text('Shout for an adult’s help.'), findsOneWidget);
    await close(tester);
  });

  testWidgets(
    'lost skips repeated helper questions and gates both phone actions',
    (tester) async {
      phone.contacts = const [
        TrustedContact(name: 'Demo adult', phone: '+48123456789'),
      ];
      await open(tester);
      await tap(tester, 'No one can help');
      await tap(tester, 'I am lost');
      expect(find.text('Stay here unless there is danger.'), findsOneWidget);
      expect(find.text('Call trusted adult'), findsNothing);
      expect(find.text('Call 112'), findsNothing);
      await service(tester, HelpPhoneService.available);
      expect(find.text('Call trusted adult'), findsOneWidget);
      expect(find.text('Call 112'), findsOneWidget);
      await service(tester, HelpPhoneService.emergencyOnly);
      expect(find.text('Call trusted adult'), findsNothing);
      expect(find.text('Call 112'), findsOneWidget);
      await tap(tester, 'Someone can help now');
      expect(find.text('Tell that adult what happened.'), findsOneWidget);
      expect(find.text('Call 112'), findsNothing);
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
          SafePoint(name: 'Home', latitude: 50.005, longitude: 20.001),
        ],
      );
      location.updates.add(fix(DateTime.now()));
      await tester.pumpAndSettle();
      expect(find.textContaining('You may be near Home'), findsOneWidget);
      expect(find.text('Can someone nearby help you?'), findsOneWidget);
      await service(tester, HelpPhoneService.available);
      await tap(tester, 'No one can help');
      await tap(tester, 'Air raid');
      expect(find.text('Inside a building'), findsOneWidget);
      expect(find.text('Outside'), findsOneWidget);
      expect(find.text('Call 112'), findsNothing);
      await close(tester);
    },
  );

  testWidgets(
    'backgrounding clears service and GPS until fresh updates arrive',
    (tester) async {
      await open(tester);
      await service(tester, HelpPhoneService.available);
      await tap(tester, 'No one can help');
      await tap(tester, 'I don’t know');
      expect(find.text('Call 112'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.paused,
      );
      await tester.pumpAndSettle();
      expect(phone.updates.hasListener, isFalse);
      expect(location.updates.hasListener, isFalse);
      tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();
      expect(phone.updates.hasListener, isTrue);
      expect(find.text('Call 112'), findsNothing);
      await service(tester, HelpPhoneService.available);
      expect(find.text('Call 112'), findsOneWidget);
      expect(location.requests, 0);
      await close(tester);
    },
  );
}
