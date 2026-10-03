/// Local family records: encrypted on Android, ephemeral in the browser demo.
/// No network or authentication gate.
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../platform/app_storage.dart';

import 'family_plan.dart';

class FamilyPlanRepository {
  FamilyPlanRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? defaultAppStorage();

  static const _key = 'basebound.family_plan.v1';
  final FlutterSecureStorage _storage;

  /// An empty saved plan still counts as existing setup, not a fresh install.
  Future<bool> hasSavedPlan() async => await _storage.read(key: _key) != null;

  Future<FamilyPlan> load() async {
    final source = await _storage.read(key: _key);
    if (source == null) return const FamilyPlan();
    return FamilyPlan.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  Future<void> save(FamilyPlan plan) async {
    if (plan.contacts.length > FamilyPlan.maxContacts) {
      throw ArgumentError('At most three trusted contacts are supported');
    }
    await _storage.write(key: _key, value: jsonEncode(plan.toJson()));
  }

  /// Deletes this feature's record, without deleting another feature's secrets.
  Future<void> deleteAll() => _storage.delete(key: _key);
}
