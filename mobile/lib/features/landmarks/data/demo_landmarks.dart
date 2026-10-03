import 'package:flutter/services.dart';

import 'landmark.dart';
import 'landmark_repository.dart';

/// Generated photos at fictional map positions, independent of one another.
/// Stable IDs make repeated imports additive and preserve parent edits.
const demoLandmarks = [
  (
    landmark: Landmark(
      id: '100_1',
      name: 'Red corner shop',
      photoName: '100_1.photo',
      latitude: 50.0685,
      longitude: 19.9865,
      isDemo: true,
    ),
    asset: 'assets/landmarks/red-shop.png',
  ),
  (
    landmark: Landmark(
      id: '100_2',
      name: 'Yellow slide',
      photoName: '100_2.photo',
      latitude: 50.0722,
      longitude: 19.9955,
      isDemo: true,
    ),
    asset: 'assets/landmarks/yellow-slide.png',
  ),
  (
    landmark: Landmark(
      id: '100_3',
      name: 'Blue bus stop',
      photoName: '100_3.photo',
      latitude: 50.0643,
      longitude: 19.9938,
      isDemo: true,
    ),
    asset: 'assets/landmarks/blue-bus-stop.png',
  ),
];

Future<int> loadDemoLandmarks(LandmarkRepository repository) async {
  final savedIds = (await repository.load()).map((entry) => entry.id).toSet();
  var added = 0;
  for (final demo in demoLandmarks) {
    if (savedIds.contains(demo.landmark.id)) continue;
    final bytes = await rootBundle.load(demo.asset);
    await repository.save(
      demo.landmark,
      photoBytes: bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      ),
    );
    added++;
  }
  return added;
}
