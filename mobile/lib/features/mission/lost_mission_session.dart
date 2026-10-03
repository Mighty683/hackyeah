import 'data/lost_practice_context.dart';
import 'lost_mission_models.dart';
import 'lost_mission_content.dart';

/// Offline decision practice. Calls, reunion and confirmation are fictional.
/// Each decision waits for feedback acknowledgment; mistakes retry in place.
class LostMissionSession {
  LostMissionSession({required this.variant, required this.context}) {
    _steps = buildLostMissionSteps(context, variant);
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

  LostMissionStep get step => _stepId == 'no_answer'
      ? lostNoAnswerStep(context, _firstContactId)
      : _steps[_stepId]!;
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

  /// Map exploration never implies walking. Asking for help uses the stay branch.
  void useMapHelp() {
    if (_stepId != 'map_meeting_point' || hasFeedback || _isComplete) return;
    _stepId = 'point_unavailable';
  }

  String? _nextStepId() => switch (_stepId) {
    'stop' => 'look',
    'look' =>
      variant == LostPracticeVariant.meetingPointNearby
          ? 'meeting_point'
          : 'point_unavailable',
    'meeting_point' =>
      context.photoMeetingPoint == null ? 'arrive' : 'map_meeting_point',
    'map_meeting_point' => 'arrive',
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
}
