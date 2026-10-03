import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../landmarks/data/demo_landmarks.dart';
import '../../landmarks/data/landmark_repository.dart';
import '../../parent/data/family_plan.dart';
import '../../parent/data/family_plan_repository.dart';

/// Fictional training destination, not a verified home or safe place.
const demoHome = SafePoint(
  name: 'Home',
  latitude: 50.0704,
  longitude: 19.9828,
  isDemo: true,
);

/// Seeds a fresh installation once. The marker survives user data deletion;
/// a pending marker resumes interrupted writes without resetting saved data.
class DemoDataSeeder {
  DemoDataSeeder({
    FlutterSecureStorage? storage,
    FamilyPlanRepository? familyRepository,
    LandmarkRepository? landmarkRepository,
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(resetOnError: false),
           ),
       _familyRepository =
           familyRepository ?? FamilyPlanRepository(storage: storage),
       _landmarkRepository =
           landmarkRepository ?? LandmarkRepository(storage: storage);

  static const storageKey = 'basebound.demo_seed.v1';
  final FlutterSecureStorage _storage;
  final FamilyPlanRepository _familyRepository;
  final LandmarkRepository _landmarkRepository;

  Future<void> seed() async {
    final state = await _storage.read(key: storageKey);
    if (state == 'complete') return;
    if (state != null && state != 'pending') {
      throw const FormatException('Unsupported demo seed state');
    }
    if (state == null) {
      final hasFamily = await _familyRepository.hasSavedPlan();
      final hasLandmarks =
          await _storage.read(key: LandmarkRepository.storageKey) != null;
      if (hasFamily || hasLandmarks) {
        await _storage.write(key: storageKey, value: 'complete');
        return;
      }
      await _storage.write(key: storageKey, value: 'pending');
    }

    final plan = await _familyRepository.load();
    if (plan.safePoints.isEmpty) {
      await _familyRepository.save(plan.copyWith(safePoints: [demoHome]));
    }
    await _removeInterruptedPhotoCopies();
    await loadDemoLandmarks(_landmarkRepository);
    final seededPlan = await _familyRepository.load();
    if (seededPlan.practiceMeetingPoint == null) {
      final meetingPlace = (await _landmarkRepository.load()).firstWhere(
        (place) => place.id == demoLandmarks.first.landmark.id,
      );
      await _familyRepository.save(
        seededPlan.copyWith(
          practiceMeetingPoint: PracticeMeetingPoint(
            landmarkId: meetingPlace.id,
            label: meetingPlace.name,
          ),
        ),
      );
    }
    await _storage.write(key: storageKey, value: 'complete');
  }

  // A process can stop after copying a bundled photo but before saving metadata.
  // Only missing seed IDs may have their app-private orphan copies replaced.
  Future<void> _removeInterruptedPhotoCopies() async {
    final savedIds = (await _landmarkRepository.load())
        .map((entry) => entry.id)
        .toSet();
    final directory = await _landmarkRepository.photoDirectory();
    for (final demo in demoLandmarks) {
      if (savedIds.contains(demo.landmark.id)) continue;
      final photo = File('${directory.path}/${demo.landmark.photoName}');
      if (await photo.exists()) await photo.delete();
    }
  }
}
