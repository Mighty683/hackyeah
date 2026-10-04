/// The displayed and spoken reminders share the same short practice recap.
abstract final class LostPracticeRecap {
  static const praise = 'Dobra robota! Ćwiczenie ukończone.';
  static const notice = 'Nie wysłano żadnej wiadomości.';
  static const points = [
    (
      title: 'Zatrzymaj się i rozejrzyj',
      description:
          'Idź do miejsca spotkania tylko wtedy, gdy widzisz je blisko.',
    ),
    (
      title: 'Poproś o pomoc tutaj',
      description: 'Skontaktuj się z rodziną. Zostań tutaj i czekaj.',
    ),
    (
      title: 'Po spotkaniu dotknij Jestem w bezpiecznym miejscu',
      description:
          'Potwierdź dopiero, gdy w tej historii znów jesteście razem.',
    ),
  ];

  static String get narration =>
      '$praise ${points.map((point) => '${point.title}. ${point.description}').join(' ')} $notice';
}

enum LostPracticeVariant { meetingPointNearby, meetingPointUnavailable }

enum LostMissionVisual {
  square,
  look,
  meetingPoint,
  helper,
  stranger,
  contacts,
  calling,
  waiting,
  reunion,
  confirmation,
  recall,
}

enum LostActionIcon {
  stop,
  search,
  leave,
  look,
  meetingPoint,
  staff,
  unknownAdult,
  stay,
  call,
  wait,
  safe,
  next,
  mother,
  father,
  grandparent,
  adult,
}

class LostMissionChoice {
  const LostMissionChoice({
    required this.id,
    required this.label,
    required this.icon,
    required this.isCorrect,
    required this.feedback,
    this.contactId,
    this.landmarkPresetId,
    this.photoPath,
    this.isDemoPhoto = false,
  });

  final String id;
  final String label;
  final LostActionIcon icon;
  final bool isCorrect;
  final String feedback;
  final String? contactId;
  final String? landmarkPresetId;
  final String? photoPath;
  final bool isDemoPhoto;
}

class LostMissionStep {
  const LostMissionStep({
    required this.id,
    required this.title,
    required this.narration,
    required this.visual,
    this.choices = const [],
    this.actionLabel = 'Rozejrzyj się',
  });

  final String id;
  final String title;
  final String narration;
  final LostMissionVisual visual;
  final List<LostMissionChoice> choices;
  final String actionLabel;
  bool get isDecision => choices.isNotEmpty;
}
