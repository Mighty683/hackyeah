/// A fictional, offline practice sequence. It never contacts real people or
/// interprets real alerts; reviewed local instructions take precedence.
enum MissionMode { home, outdoor }

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

  /// Outdoor destination mistakes lead to a guided physical-action branch.
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

/// Each decision waits for the child to acknowledge calm spoken feedback.
/// Home mistakes can be retried; outdoor mistakes teach a recovery action.
class MissionSession {
  MissionSession({required this.mode}) {
    _steps = _buildSteps();
    restart();
  }

  final MissionMode mode;
  late final Map<String, MissionStep> _steps;
  late String _stepId;
  MissionChoice? _selectedChoice;
  bool _isComplete = false;

  MissionStep get step => _steps[_stepId]!;
  MissionChoice? get selectedChoice => _selectedChoice;
  String? get feedback => _selectedChoice?.feedback;
  bool get hasFeedback => _selectedChoice != null;
  bool get isComplete => _isComplete;

  void choose(String id) {
    if (_isComplete || hasFeedback) return;
    for (final choice in step.choices) {
      if (choice.id == id) {
        _selectedChoice = choice;
        return;
      }
    }
  }

  void advance() {
    if (_isComplete) return;
    if (step.isDecision && !hasFeedback) return;
    final choice = _selectedChoice;
    if (choice != null && !choice.isCorrect && !choice.continuesAfterFeedback) {
      return;
    }
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
    _stepId = mode == MissionMode.home ? 'alarm' : 'outdoor_alarm';
    _selectedChoice = null;
    _isComplete = false;
  }

  String? _nextStepId() {
    switch (_stepId) {
      case 'alarm':
        return 'room';
      case 'room':
        return 'apartment';
      case 'apartment':
      case 'outdoor_sheltered':
        return 'contacts';
      case 'contacts':
        return 'communication';
      case 'communication':
        return 'message';
      case 'message':
        return 'noise';
      case 'noise':
        return 'quiet';
      case 'quiet':
        return 'all_clear';
      case 'all_clear':
        return 'recall';
      case 'recall':
        return null;
      case 'outdoor_alarm':
        return 'destination';
      case 'destination':
        if (_selectedChoice!.id == 'more_places') return 'outdoor_places';
        return _selectedChoice!.isCorrect ? 'outdoor_sheltered' : 'get_down';
      case 'outdoor_places':
        return _selectedChoice!.isCorrect ? 'outdoor_sheltered' : 'get_down';
      case 'get_down':
        return 'protect_head';
      case 'protect_head':
        return 'outdoor_sheltered';
      default:
        throw StateError('Unknown mission step: $_stepId');
    }
  }
}

Map<String, MissionStep> _buildSteps() {
  final steps = <MissionStep>[
    const MissionStep(
      id: 'alarm',
      title: 'An alarm at home',
      narration:
          'This is an alarm. In this practice, you cannot reach a shelter. '
          'Find a safer place inside your home, away from windows.',
      visual: MissionVisual.alarm,
      sound: 'alarm',
    ),
    MissionStep(
      id: 'room',
      title: 'Where will you go?',
      narration: 'The alarm has started. What will you do?',
      visual: MissionVisual.room,
      choices: [
        _choice(
          'window',
          'Go to the window',
          MissionActionIcon.window,
          false,
          'Windows are less safe. Move away from them.',
        ),
        _choice(
          'door',
          'Go outside',
          MissionActionIcon.door,
          false,
          'In this practice, stay inside and find a safer place.',
        ),
        _choice(
          'interior',
          'Move deeper inside',
          MissionActionIcon.interior,
          true,
          'Good. You moved away from the windows.',
        ),
      ],
    ),
    MissionStep(
      id: 'apartment',
      title: 'Choose a room',
      narration: 'Find a place away from the windows.',
      visual: MissionVisual.apartment,
      choices: [
        _choice(
          'living_room',
          'Living room',
          MissionActionIcon.livingRoom,
          false,
          'There is a window here. Find a place deeper inside.',
        ),
        _choice(
          'bedroom',
          'Bedroom',
          MissionActionIcon.bedroom,
          false,
          'There is a window here. Find a place deeper inside.',
        ),
        _choice(
          'kitchen',
          'Kitchen',
          MissionActionIcon.kitchen,
          false,
          'There is a window here. Find a place deeper inside.',
        ),
        _choice(
          'hallway',
          'Inside hallway',
          MissionActionIcon.hallway,
          true,
          'Two walls help protect you.',
          visual: MissionVisual.twoWalls,
        ),
      ],
    ),
    MissionStep(
      id: 'contacts',
      title: 'Tell a trusted adult',
      narration: 'You are away from windows. Choose a trusted adult.',
      visual: MissionVisual.contacts,
      choices: [
        _choice(
          'mom',
          'Mom',
          MissionActionIcon.mom,
          true,
          'Let Mom know where you are. This is pretend.',
        ),
        _choice(
          'dad',
          'Dad',
          MissionActionIcon.dad,
          true,
          'Let Dad know where you are. This is pretend.',
        ),
        _choice(
          'grandparent',
          'Grandparent',
          MissionActionIcon.grandparent,
          true,
          'Let your grandparent know where you are. This is pretend.',
        ),
      ],
    ),
    MissionStep(
      id: 'communication',
      title: 'How will you tell them?',
      narration: 'Send one short message to your trusted adult.',
      visual: MissionVisual.communication,
      choices: [
        _choice(
          'call',
          'Keep calling',
          MissionActionIcon.call,
          false,
          'Repeated calls can keep lines busy. Try one short message.',
        ),
        _choice(
          'message',
          'Send one message',
          MissionActionIcon.message,
          true,
          'Your pretend message says: I am away from windows.',
        ),
      ],
    ),
    const MissionStep(
      id: 'message',
      title: 'A pretend reply',
      narration:
          'Your message says: I am away from windows. '
          'Your trusted adult replies: Good. Stay there and wait for the all-clear.',
      visual: MissionVisual.message,
    ),
    MissionStep(
      id: 'noise',
      title: 'You hear a loud noise',
      narration: 'You hear a loud noise. What will you do?',
      visual: MissionVisual.sheltered,
      sound: 'noise',
      choices: [
        _choice(
          'window',
          'Go to the window',
          MissionActionIcon.window,
          false,
          'Do not go to the window yet. Stay away from windows.',
        ),
        _choice(
          'door',
          'Go to the door',
          MissionActionIcon.door,
          false,
          'Do not go outside yet. Stay in the protected place.',
        ),
        _choice(
          'stay',
          'Stay here',
          MissionActionIcon.stay,
          true,
          'Good. Stay here.',
        ),
      ],
    ),
    MissionStep(
      id: 'quiet',
      title: 'It is quiet now',
      narration: 'It is quiet now. What will you do?',
      visual: MissionVisual.quiet,
      choices: [
        _choice(
          'leave',
          'Leave now',
          MissionActionIcon.leave,
          false,
          'Quiet does not mean the danger is over. Wait for the all-clear.',
        ),
        _choice(
          'stay',
          'Stay and wait',
          MissionActionIcon.stay,
          true,
          'Good. Stay and wait for the all-clear.',
        ),
      ],
    ),
    const MissionStep(
      id: 'all_clear',
      title: 'The all-clear',
      narration:
          'In this practice, the official all-clear arrives. '
          'Now follow instructions from adults or emergency services.',
      visual: MissionVisual.allClear,
      sound: 'all_clear',
    ),
    const MissionStep(
      id: 'recall',
      title: 'You finished the practice',
      narration:
          'Alarm. Move away from windows. Find a protected place. '
          'Message someone you trust. Stay there until the all-clear.',
      visual: MissionVisual.recall,
    ),
    const MissionStep(
      id: 'outdoor_alarm',
      title: 'An alarm on your walk',
      narration: 'In this pretend street, you hear the alarm.',
      visual: MissionVisual.street,
      sound: 'alarm',
    ),
    MissionStep(
      id: 'destination',
      title: 'Where will you go?',
      narration: 'You hear the alarm. Choose where to go.',
      visual: MissionVisual.street,
      choices: [
        _choice(
          'home',
          'Home: far away',
          MissionActionIcon.home,
          false,
          'Home is far away. You are still outside when a loud noise starts.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'school',
          'School: farther away',
          MissionActionIcon.school,
          false,
          'School is farther away. You hear a loud noise outside.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'shelter',
          'Nearby solid shelter',
          MissionActionIcon.shelter,
          true,
          'You reached the nearby practice shelter, away from windows.',
        ),
        _choice(
          'more_places',
          'Look at other places',
          MissionActionIcon.next,
          true,
          'Look at the park, bus stop and nearby shelter.',
        ),
      ],
    ),
    MissionStep(
      id: 'outdoor_places',
      title: 'Choose a nearby place',
      narration: 'Which nearby place will you choose?',
      visual: MissionVisual.street,
      choices: [
        _choice(
          'park',
          'Park',
          MissionActionIcon.park,
          false,
          'The open park offers little protection. You hear a loud noise.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'bus_stop',
          'Bus stop',
          MissionActionIcon.busStop,
          false,
          'The bus stop offers little protection. You hear a loud noise.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'shelter',
          'Nearby solid shelter',
          MissionActionIcon.shelter,
          true,
          'You reached the nearby practice shelter, away from windows.',
        ),
      ],
    ),
    MissionStep(
      id: 'get_down',
      title: 'A loud noise outside',
      narration: 'You are outside. Get down.',
      visual: MissionVisual.getDown,
      sound: 'noise',
      choices: [
        _choice(
          'stay',
          'Keep standing',
          MissionActionIcon.stay,
          false,
          'Get down to make yourself lower.',
        ),
        _choice(
          'down',
          'Get down',
          MissionActionIcon.down,
          true,
          'You got down. Now protect your head.',
        ),
      ],
    ),
    MissionStep(
      id: 'protect_head',
      title: 'Protect your head',
      narration: 'Stay down and protect your head.',
      visual: MissionVisual.protectHead,
      choices: [
        _choice(
          'stay',
          'Arms by your side',
          MissionActionIcon.stay,
          false,
          'Use your arms to cover your head.',
        ),
        _choice(
          'protect_head',
          'Cover your head',
          MissionActionIcon.protectHead,
          true,
          'Good. Stay down with your head protected.',
        ),
      ],
    ),
    const MissionStep(
      id: 'outdoor_sheltered',
      title: 'Inside the practice shelter',
      narration:
          'In this practice, a trusted adult helps you reach shelter '
          'when it is possible. You stay away from windows.',
      visual: MissionVisual.sheltered,
    ),
  ];
  return {for (final step in steps) step.id: step};
}

MissionChoice _choice(
  String id,
  String label,
  MissionActionIcon icon,
  bool correct,
  String feedback, {
  MissionVisual? visual,
  bool continuesAfterFeedback = false,
}) => MissionChoice(
  id: id,
  label: label,
  icon: icon,
  isCorrect: correct,
  feedback: feedback,
  visual: visual,
  continuesAfterFeedback: continuesAfterFeedback,
);
