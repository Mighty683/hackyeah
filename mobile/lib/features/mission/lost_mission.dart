import 'data/lost_practice_context.dart';
import 'lost_landmarks.dart';

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
  });

  final String id;
  final String label;
  final LostActionIcon icon;
  final bool isCorrect;
  final String feedback;
  final String? contactId;
  final String? landmarkPresetId;
}

class LostMissionStep {
  const LostMissionStep({
    required this.id,
    required this.title,
    required this.narration,
    required this.visual,
    this.choices = const [],
    this.actionLabel = 'Look around',
  });

  final String id;
  final String title;
  final String narration;
  final LostMissionVisual visual;
  final List<LostMissionChoice> choices;
  final String actionLabel;
  bool get isDecision => choices.isNotEmpty;
}

/// Offline decision practice. Calls, reunion and confirmation are fictional.
/// Each decision waits for feedback acknowledgment; mistakes retry in place.
class LostMissionSession {
  LostMissionSession({required this.variant, required this.context}) {
    _steps = _buildSteps();
    restart();
  }

  final LostPracticeVariant variant;
  final LostPracticeContext context;

  late final Map<String, LostMissionStep> _steps;
  late String _stepId;
  LostMissionChoice? _selectedChoice;
  String? _firstContactId;
  bool _safetyConfirmed = false;
  bool _isComplete = false;

  LostMissionStep get step =>
      _stepId == 'no_answer' ? _noAnswerStep() : _steps[_stepId]!;
  LostMissionChoice? get selectedChoice => _selectedChoice;
  String? get feedback => _selectedChoice?.feedback;
  bool get hasFeedback => _selectedChoice != null;
  bool get isComplete => _isComplete;
  String? get firstContactId => _firstContactId;
  bool get safetyConfirmed => _safetyConfirmed;

  void choose(String id) {
    if (_isComplete || hasFeedback) return;
    for (final choice in step.choices) {
      if (choice.id == id) {
        _selectedChoice = choice;
        return;
      }
    }
  }

  /// Observation actions advance directly; decisions require a safe choice.
  /// Advancing the explicit I'M SAFE action changes local training state only.
  void advance() {
    if (_isComplete) return;
    if (step.isDecision && _selectedChoice?.isCorrect != true) return;
    if (_stepId == 'contact') {
      _firstContactId = _selectedChoice!.contactId;
    }
    if (_stepId == 'confirm_safe') _safetyConfirmed = true;
    final nextId = _nextStepId();
    if (nextId == null) {
      _isComplete = true;
      return;
    }
    _stepId = nextId;
    _selectedChoice = null;
  }

  void retry() {
    if (_isComplete || _selectedChoice?.isCorrect != false) return;
    _selectedChoice = null;
  }

  void restart() {
    _stepId = 'stop';
    _selectedChoice = null;
    _firstContactId = null;
    _safetyConfirmed = false;
    _isComplete = false;
  }

  String? _nextStepId() => switch (_stepId) {
    'stop' => 'look',
    'look' =>
      variant == LostPracticeVariant.meetingPointNearby
          ? 'meeting_point'
          : 'point_unavailable',
    'meeting_point' => 'arrive',
    'arrive' || 'point_unavailable' => 'helper',
    'helper' => 'stranger',
    'stranger' => 'contact',
    'contact' => 'no_answer',
    'no_answer' => 'reply',
    'reply' => 'wait',
    'wait' => 'reunion',
    'reunion' => 'confirm_safe',
    'confirm_safe' => 'confirmation',
    'confirmation' => 'recall',
    'recall' => null,
    _ => throw StateError('Unknown lost practice step: $_stepId'),
  };

  Map<String, LostMissionStep> _buildSteps() {
    final landmark = resolveLostLandmark(context.meetingPoint.presetId);
    final otherLandmark = resolveLostLandmark(
      landmark.id == 'fountain' ? 'information_desk' : 'fountain',
    );
    final steps = <LostMissionStep>[
      LostMissionStep(
        id: 'stop',
        title: 'You cannot see your parent',
        narration: 'You cannot see your parent. What will you do?',
        visual: LostMissionVisual.square,
        choices: [
          _choice(
            'search',
            'Run and search',
            LostActionIcon.search,
            false,
            'Running away makes it harder to find you. Stop first.',
          ),
          _choice(
            'leave',
            'Leave this place',
            LostActionIcon.leave,
            false,
            'Your parent may look here. Stop and look around.',
          ),
          _choice(
            'stop',
            'Stop and look',
            LostActionIcon.stop,
            true,
            'Good. You stopped. Now look around.',
          ),
        ],
      ),
      LostMissionStep(
        id: 'look',
        title: 'Remember your meeting place',
        narration:
            'Look around. Your practice meeting place is '
            '${context.meetingPointLabel}.',
        visual: LostMissionVisual.look,
        actionLabel: variant == LostPracticeVariant.meetingPointNearby
            ? 'Find the meeting place'
            : 'Look for nearby help',
      ),
      LostMissionStep(
        id: 'meeting_point',
        title: 'Which is your meeting place?',
        narration: 'Your meeting place is visible nearby. Choose it.',
        visual: LostMissionVisual.meetingPoint,
        choices: [
          LostMissionChoice(
            id: landmark.id,
            label: context.meetingPointLabel,
            icon: LostActionIcon.meetingPoint,
            isCorrect: true,
            feedback: 'Yes. You recognize your nearby practice meeting place.',
            landmarkPresetId: landmark.id,
          ),
          LostMissionChoice(
            id: otherLandmark.id,
            label: otherLandmark.label,
            icon: LostActionIcon.meetingPoint,
            isCorrect: false,
            feedback:
                'That is a different landmark. Remember your meeting place.',
            landmarkPresetId: otherLandmark.id,
          ),
          _choice(
            'leave',
            'Go to the exit',
            LostActionIcon.leave,
            false,
            'Leaving makes it harder to find you. Choose your nearby meeting place.',
          ),
        ],
      ),
      LostMissionStep(
        id: 'arrive',
        title: 'At your practice meeting place',
        narration:
            'In this story, you reach ${context.meetingPointLabel}. '
            'Staff can help nearby.',
        visual: LostMissionVisual.meetingPoint,
        actionLabel: 'Ask for nearby help',
      ),
      LostMissionStep(
        id: 'point_unavailable',
        title: 'Your meeting place is out of sight',
        narration: 'You cannot see your meeting place. What will you do?',
        visual: LostMissionVisual.square,
        choices: [
          _choice(
            'leave',
            'Walk through new streets',
            LostActionIcon.leave,
            false,
            'New streets may make you more lost. Stay nearby.',
          ),
          _choice(
            'search',
            'Keep searching alone',
            LostActionIcon.search,
            false,
            'Searching alone makes it harder to find you. Ask nearby staff.',
          ),
          _choice(
            'stay',
            'Stay nearby and ask for help',
            LostActionIcon.stay,
            true,
            'Good. Stay nearby. Look for help at the information desk.',
          ),
        ],
      ),
      LostMissionStep(
        id: 'helper',
        title: 'Who can help here?',
        narration: 'Find help here, where people can see you.',
        visual: LostMissionVisual.helper,
        choices: [
          _choice(
            'staff',
            'Ask staff at the desk',
            LostActionIcon.staff,
            true,
            'Ask staff to contact your family. Stay here at the desk.',
          ),
          _choice(
            'unknown_adult',
            'Follow someone away',
            LostActionIcon.unknownAdult,
            false,
            'Going somewhere unknown makes you harder to find. Ask for help here.',
          ),
          _choice(
            'search',
            'Keep searching alone',
            LostActionIcon.search,
            false,
            'Searching alone makes it harder to find you. Ask for help here.',
          ),
        ],
      ),
      LostMissionStep(
        id: 'stranger',
        title: 'Someone asks you to follow',
        narration: 'Someone says: Come with me to find your parent.',
        visual: LostMissionVisual.stranger,
        choices: [
          _choice(
            'leave',
            'Go with them',
            LostActionIcon.leave,
            false,
            'Stay where people can find you. Ask staff to contact your family.',
          ),
          _choice(
            'stay',
            'Stay here and ask staff',
            LostActionIcon.stay,
            true,
            'Good. You stayed here and asked staff to contact your family.',
          ),
        ],
      ),
      LostMissionStep(
        id: 'contact',
        title: 'Pretend to call your family',
        narration: 'Choose a trusted person. This call is pretend.',
        visual: LostMissionVisual.contacts,
        choices: context.contacts.map(_contactChoice).toList(growable: false),
      ),
      const LostMissionStep(
        id: 'reply',
        title: 'A pretend reply',
        narration:
            'In this story, your family knows where you are. '
            'Staff stay with you.',
        visual: LostMissionVisual.calling,
        actionLabel: 'Stay with staff',
      ),
      LostMissionStep(
        id: 'wait',
        title: 'Your parent is coming',
        narration: 'Your parent is coming in the story. What will you do?',
        visual: LostMissionVisual.waiting,
        choices: [
          _choice(
            'leave',
            'Leave and search',
            LostActionIcon.leave,
            false,
            'Your family knows this place. Stay here so they can find you.',
          ),
          _choice(
            'stay',
            'Stay here and wait',
            LostActionIcon.wait,
            true,
            'Good. Stay here with staff. Your parent is coming.',
          ),
        ],
      ),
      const LostMissionStep(
        id: 'reunion',
        title: 'Your parent arrives',
        narration: 'Your parent arrives in this story. You are together again.',
        visual: LostMissionVisual.reunion,
        actionLabel: 'Say I am safe',
      ),
      const LostMissionStep(
        id: 'confirm_safe',
        title: 'You are together again',
        narration: 'Tap I am safe. This is only practice.',
        visual: LostMissionVisual.reunion,
        actionLabel: "I'M SAFE",
      ),
      const LostMissionStep(
        id: 'confirmation',
        title: 'Your pretend confirmation',
        narration: 'Practice complete. No message was sent.',
        visual: LostMissionVisual.confirmation,
        actionLabel: 'Remember the steps',
      ),
      const LostMissionStep(
        id: 'recall',
        title: 'Remember what you practiced',
        narration:
            'Stop. Look around. Use your meeting place only if it is '
            'visible nearby. Ask for help here. Contact your family. '
            'Stay and wait. After reunion, tap I am safe.',
        visual: LostMissionVisual.recall,
        actionLabel: 'Finish practice',
      ),
    ];
    return {for (final step in steps) step.id: step};
  }

  LostMissionStep _noAnswerStep() => LostMissionStep(
    id: 'no_answer',
    title: 'The pretend call has no answer',
    narration: 'Stay with staff. Try a different trusted person.',
    visual: LostMissionVisual.contacts,
    choices: [
      for (final contact in context.contacts)
        if (contact.id != _firstContactId) _contactChoice(contact),
      _choice(
        'leave',
        'Leave and search',
        LostActionIcon.leave,
        false,
        'Stay with staff. Try another trusted person here.',
      ),
    ],
  );
}

LostMissionChoice _contactChoice(
  LostPracticeContact contact,
) => LostMissionChoice(
  id: contact.id,
  label: 'Pretend call: ${contact.label}',
  icon: switch (contact.avatar) {
    LostContactAvatar.mother => LostActionIcon.mother,
    LostContactAvatar.father => LostActionIcon.father,
    LostContactAvatar.grandparent => LostActionIcon.grandparent,
    LostContactAvatar.adult => LostActionIcon.adult,
  },
  isCorrect: true,
  feedback: contact.isFictional
      ? 'You chose ${contact.label}, a pretend person. This call is pretend.'
      : 'You chose ${contact.label}. This call is pretend.',
  contactId: contact.id,
);

LostMissionChoice _choice(
  String id,
  String label,
  LostActionIcon icon,
  bool isCorrect,
  String feedback,
) => LostMissionChoice(
  id: id,
  label: label,
  icon: icon,
  isCorrect: isCorrect,
  feedback: feedback,
);
