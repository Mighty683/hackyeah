import 'data/lost_practice_context.dart';
import 'lost_mission_models.dart';
import 'lost_mission_content.dart';

/// Offline decision practice. Calls, reunion and confirmation are fictional.
/// Mistakes disable only that choice; accepted decisions lock until advancement.
/// Map recognition keeps its native pins selectable and repeats their feedback.
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
  final Set<String> _rejectedChoiceIds = {};
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
  bool get canChoose => !_isComplete && _selectedChoice?.isCorrect != true;
  Set<String> get rejectedChoiceIds => Set.unmodifiable(_rejectedChoiceIds);

  void choose(String id) {
    if (!canChoose || _rejectedChoiceIds.contains(id)) return;
    for (final choice in step.choices) {
      if (choice.id == id) {
        _selectedChoice = choice;
        if (!choice.isCorrect && _stepId != 'map_meeting_point') {
          _rejectedChoiceIds.add(id);
        }
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
    _rejectedChoiceIds.clear();
  }

  void retry() {
    if (_isComplete || _selectedChoice?.isCorrect != false) return;
    _selectedChoice = null;
  }

  void restart() {
    _stepId = 'stop';
    _selectedChoice = null;
    _rejectedChoiceIds.clear();
    _firstContactId = null;
    _safetyConfirmed = false;
    _isComplete = false;
  }

  /// Map exploration never implies walking. Asking for help uses the stay branch.
  void useMapHelp() {
    if (_stepId != 'map_meeting_point' || !canChoose) return;
    _stepId = 'point_unavailable';
    _selectedChoice = null;
    _rejectedChoiceIds.clear();
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
