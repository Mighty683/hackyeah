/// Explicit dialler handoff only: no automatic calls, SMS, or delivery tracking.
library;

import 'package:url_launcher/url_launcher.dart';

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
  Future<List<TrustedContact>> loadContacts() async {
    final plan = await FamilyPlanRepository().load();
    return plan.contacts
        .where((contact) => normalizeTrustedPhone(contact.phone) != null)
        .toList(growable: false);
  }

  /// Success means a phone app opened, not that a call connected.
  Future<bool> openDialler(String phone) => launchUrl(
    Uri(scheme: 'tel', path: phone),
    mode: LaunchMode.externalApplication,
  );
}
