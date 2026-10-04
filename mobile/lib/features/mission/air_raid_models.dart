/// A fictional, offline practice sequence. It never contacts real people or
/// interprets real alerts; reviewed local instructions take precedence.
enum MissionMode { home, outdoor }

/// The same three reminders are shown and narrated at the end of practice.
abstract final class AirRaidPracticeRecap {
  static const praise = 'Dobra robota! Ćwiczenie ukończone.';
  static const points = [
    (
      title: 'Znajdź osłonięte miejsce',
      description: 'Odsuń się od okien, gdy usłyszysz alarm.',
    ),
    (
      title: 'Powiedz zaufanej osobie dorosłej',
      description: 'Spróbuj zadzwonić raz. Jeśli nikt nie odbiera, wyślij SMS.',
    ),
    (
      title: 'Czekaj na odwołanie alarmu',
      description: 'Zostań tam, nawet gdy jest cicho.',
    ),
  ];

  static String get narration =>
      '$praise ${points.map((point) => '${point.title}. ${point.description}').join(' ')}';
}

enum MissionVisual {
  alarm,
  room,
  apartment,
  twoWalls,
  contacts,
  communication,
  message,
  sheltered,
  quiet,
  allClear,
  recall,
  street,
  getDown,
  protectHead,
}

enum MissionActionIcon {
  window,
  door,
  interior,
  livingRoom,
  bedroom,
  kitchen,
  hallway,
  mom,
  dad,
  grandparent,
  call,
  message,
  stay,
  leave,
  home,
  school,
  shelter,
  park,
  busStop,
  down,
  protectHead,
  next,
  replay,
}

class MissionChoice {
  const MissionChoice({
    required this.id,
    required this.label,
    required this.icon,
    required this.isCorrect,
    required this.feedback,
    this.visual,
    this.continuesAfterFeedback = false,
  });

  final String id;
  final String label;
  final MissionActionIcon icon;
  final bool isCorrect;
  final String feedback;
  final MissionVisual? visual;

  /// A destination consequence leads into the guided outdoor recovery story.
  final bool continuesAfterFeedback;
}

class MissionStep {
  const MissionStep({
    required this.id,
    required this.title,
    required this.narration,
    required this.visual,
    this.choices = const [],
    this.sound,
  });

  final String id;
  final String title;
  final String narration;
  final MissionVisual visual;
  final List<MissionChoice> choices;
  final String? sound;
  bool get isDecision => choices.isNotEmpty;
}
