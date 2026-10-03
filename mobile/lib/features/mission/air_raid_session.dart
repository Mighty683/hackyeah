import 'air_raid_models.dart';
import 'air_raid_content.dart';

/// Wrong choices stay rejected until the child completes the current decision.
/// Correct choices advance after the screen presents their spoken feedback.
class MissionSession {
  MissionSession({required this.mode}) {
    _steps = buildAirRaidSteps(mode);
    restart();
  }

  final MissionMode mode;
  late final Map<String, MissionStep> _steps;
  late String _stepId;
  MissionChoice? _selectedChoice;
  String? _outdoorDestination;
  final Set<String> _rejectedChoiceIds = {};
  bool _isComplete = false;

  MissionStep get step => _stepId == 'outdoor_noise'
      ? outdoorNoiseStep(_outdoorDestination)
      : _steps[_stepId]!;
  MissionChoice? get selectedChoice => _selectedChoice;
  String? get feedback => _selectedChoice?.feedback;
  bool get hasFeedback => _selectedChoice != null;
  bool get isComplete => _isComplete;
  bool get canChoose =>
      !_isComplete &&
      _selectedChoice?.isCorrect != true &&
      _selectedChoice?.continuesAfterFeedback != true;
  Set<String> get rejectedChoiceIds => Set.unmodifiable(_rejectedChoiceIds);

  void choose(String id) {
    if (!canChoose || _rejectedChoiceIds.contains(id)) return;
    for (final choice in step.choices) {
      if (choice.id == id) {
        _selectedChoice = choice;
        if ((_stepId == 'destination' || _stepId == 'outdoor_places') &&
            !choice.isCorrect) {
          _outdoorDestination = choice.id;
        }
        if (!choice.isCorrect && !choice.continuesAfterFeedback) {
          _rejectedChoiceIds.add(id);
        }
        return;
      }
    }
  }

  void advance() {
    if (_isComplete) return;
    if (step.isDecision && !hasFeedback) return;
    if (_selectedChoice?.isCorrect == false &&
        _selectedChoice?.continuesAfterFeedback != true) {
      return;
    }
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
    _stepId = mode == MissionMode.home ? 'alarm' : 'outdoor_alarm';
    _selectedChoice = null;
    _outdoorDestination = null;
    _rejectedChoiceIds.clear();
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
        return 'sms';
      case 'sms':
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
        return _selectedChoice!.isCorrect
            ? 'outdoor_sheltered'
            : 'outdoor_noise';
      case 'outdoor_places':
        return _selectedChoice!.isCorrect
            ? 'outdoor_sheltered'
            : 'outdoor_noise';
      case 'outdoor_noise':
        return 'get_down';
      case 'get_down':
        return 'protect_head';
      case 'protect_head':
        return 'outdoor_recover';
      case 'outdoor_recover':
        return 'outdoor_sheltered';
      default:
        throw StateError('Unknown mission step: $_stepId');
    }
  }
}
