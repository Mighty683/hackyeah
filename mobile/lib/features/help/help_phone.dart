/// MVP 112 mock dialog and explicit trusted-contact dialler handoff.
library;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';

/// Accept ordinary full telephone numbers, never short codes or USSD commands.
String? normalizeTrustedPhone(String input) {
  final trimmed = input.trim();
  if (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(trimmed)) return null;
  var phone = trimmed.replaceAll(RegExp(r'[ ()-]'), '');
  if (phone.startsWith('00')) phone = '+${phone.substring(2)}';
  if (!RegExp(r'^\+?[1-9][0-9]{8,14}$').hasMatch(phone)) return null;
  return phone;
}

class HelpPhone {
  static const _channel = MethodChannel('basebound/help_phone');
  static const _serviceChannel = EventChannel('basebound/help_service');

  /// Android's voice-service report; never a guarantee a call will connect.
  Stream<HelpPhoneService> serviceStates() async* {
    if (kIsWeb) {
      yield HelpPhoneService.available;
      yield* Stream<HelpPhoneService>.periodic(
        const Duration(seconds: 30),
        (_) => HelpPhoneService.available,
      );
      return;
    }
    try {
      if (await _channel.invokeMethod<bool>('hasServiceStateStream') != true) {
        yield HelpPhoneService.unknown;
        return;
      }
    } on PlatformException {
      yield HelpPhoneService.unknown;
      return;
    } on MissingPluginException {
      yield HelpPhoneService.unknown;
      return;
    }
    yield* _serviceChannel.receiveBroadcastStream().map(
      (value) => switch (value) {
        'available' => HelpPhoneService.available,
        'emergencyOnly' => HelpPhoneService.emergencyOnly,
        'unavailable' => HelpPhoneService.unavailable,
        _ => HelpPhoneService.unknown,
      },
    );
  }

  Future<List<TrustedContact>> loadContacts() async {
    final plan = await FamilyPlanRepository().load();
    return plan.contacts
        .where((contact) => normalizeTrustedPhone(contact.phone) != null)
        .toList(growable: false);
  }

  /// 112 only opens the native demo dialog; it never reaches the dialler.
  /// Other numbers open the phone app without automatically placing a call.
  Future<bool> openDialler(String phone) async {
    // Browser UI owns the pretend-call dialog; direct callers cannot launch tel.
    if (kIsWeb) return false;
    if (phone == '112') {
      return await _channel.invokeMethod<bool>('showMockEmergencyCall') ??
          false;
    }
    return launchUrl(
      Uri(scheme: 'tel', path: phone),
      mode: LaunchMode.externalApplication,
    );
  }
}

enum HelpPhoneService {
  unknown,
  unavailable,
  emergencyOnly,
  available;

  bool get canOfferEmergency => this == available || this == emergencyOnly;

  bool get canOfferContact => this == available;
}
