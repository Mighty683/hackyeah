import '../../platform/photo_access.dart';

import '../../game/maps/demo_map.dart';
import '../landmarks/data/landmark.dart';
import '../landmarks/data/landmark_repository.dart';
import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';
import 'data/lost_practice_context.dart';

/// A display-only snapshot. Loading never changes the family's saved records.
class LostPracticeSnapshot {
  const LostPracticeSnapshot({
    required this.savedPlan,
    required this.context,
    required this.map,
    required this.mapLandmarks,
    required this.photoDirectory,
    required this.needsMeetingPoint,
  });

  final FamilyPlan savedPlan;
  final LostPracticeContext context;
  final DemoMap? map;
  final List<Landmark> mapLandmarks;
  final String photoDirectory;
  final bool needsMeetingPoint;
}

/// Joins saved setup and available photos within the bundled practice map.
class LostPracticeLoader {
  const LostPracticeLoader({
    required this.familyRepository,
    required this.landmarkRepository,
    required this.child,
  });

  final FamilyPlanRepository familyRepository;
  final LandmarkRepository landmarkRepository;
  final ChildProfile child;

  Future<LostPracticeSnapshot> load() async {
    final plan = await familyRepository.load();
    final photoPlaces = <LostPracticePlace>[];
    final mapLandmarks = <Landmark>[];
    DemoMap? map;
    LostPracticeHomePoint? homePoint;
    var photoDirectory = '';
    if (plan.practiceMeetingPoint == null ||
        plan.practiceMeetingPoint?.landmarkId != null) {
      final landmarks = await landmarkRepository.load();
      final directory = await landmarkRepository.photoDirectory();
      photoDirectory = directory.path;
      final loadedMap = await DemoMapRepository().load();
      map = loadedMap;
      for (final place in landmarks) {
        final photoPath = '$photoDirectory/${place.photoName}';
        if (!loadedMap.contains(place.latitude, place.longitude) ||
            !await photoExists(photoPath)) {
          continue;
        }
        mapLandmarks.add(place);
        photoPlaces.add(
          LostPracticePlace(
            id: place.id,
            label: place.name,
            photoPath: photoPath,
            isDemo: place.isDemo,
          ),
        );
      }
      final home = plan.safePoints
          .where(
            (point) =>
                (point.name.trim().toLowerCase() == 'home' ||
                    const {'🏠', '🏡'}.contains(point.icon)) &&
                loadedMap.contains(point.latitude, point.longitude),
          )
          .firstOrNull;
      if (home != null) {
        homePoint = LostPracticeHomePoint(label: home.displayName);
        mapLandmarks.add(
          Landmark(
            id: LostPracticeHomePoint.id,
            name: home.displayName,
            photoName: '',
            latitude: home.latitude,
            longitude: home.longitude,
            icon: '🏠',
            isDestination: true,
            photoAsset: home.isDemo ? 'assets/landmarks/demo-home.png' : null,
            isDemo: home.isDemo,
          ),
        );
      }
    }
    // Older installs can start from their saved photos without rewriting setup.
    final practicePlan =
        plan.practiceMeetingPoint == null && photoPlaces.isNotEmpty
        ? plan.copyWith(
            practiceMeetingPoint: PracticeMeetingPoint(
              landmarkId: photoPlaces.first.id,
              label: photoPlaces.first.label,
            ),
          )
        : plan;
    final practice = LostPracticeContext.fromFamilyPlan(
      practicePlan,
      fallbackChild: child,
      photoPlaces: photoPlaces,
      homePoint: homePoint,
    );
    return LostPracticeSnapshot(
      savedPlan: plan,
      context: practice,
      map: map,
      mapLandmarks: mapLandmarks,
      photoDirectory: photoDirectory,
      needsMeetingPoint:
          practicePlan.practiceMeetingPoint == null ||
          practice.meetingPointUnavailable,
    );
  }
}
