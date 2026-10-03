import 'dart:math';

import 'data/landmark.dart';

/// Each question samples independent points; list order never implies a path.
class LandmarkQuestion {
  const LandmarkQuestion({required this.target, required this.choices});
  factory LandmarkQuestion.pick(
    List<Landmark> landmarks, {
    Random? random,
    String? previousId,
  }) {
    if (landmarks.length < 2) {
      throw ArgumentError('Practice needs two landmarks');
    }
    final rng = random ?? Random();
    final candidates =
        landmarks.where((entry) => entry.id != previousId).toList()
          ..shuffle(rng);
    final target = candidates.first;
    final distractors =
        landmarks.where((entry) => entry.id != target.id).toList()
          ..shuffle(rng);
    final choices = [target, ...distractors.take(3)]..shuffle(rng);
    return LandmarkQuestion(
      target: target,
      choices: List.unmodifiable(choices),
    );
  }
  final Landmark target;
  final List<Landmark> choices;
  bool isCorrect(Landmark selected) => selected.id == target.id;
}
