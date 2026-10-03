import '../../widgets/child_character.dart';
import 'data/lost_practice_context.dart';
import 'lost_landmarks.dart';
import 'lost_mission.dart';

enum LostSceneMotif {
  square,
  landmark,
  helper,
  stranger,
  phone,
  family,
  safe,
  recall,
}

class LostMissionSceneLayout {
  const LostMissionSceneLayout({
    required this.motif,
    required this.description,
    this.childPose = ChildPoseName.stand,
    this.childAtMeetingPoint = false,
  });

  final LostSceneMotif motif;
  final String description;
  final ChildPoseName childPose;
  final bool childAtMeetingPoint;
}

/// Scene metadata contains no route or real destination verification.
LostMissionSceneLayout lostMissionSceneLayout(
  LostMissionStep step,
  LostPracticeContext context,
  LostMissionChoice? selectedChoice,
) {
  final arriving =
      step.id == 'arrive' ||
      (step.id == 'meeting_point' && selectedChoice?.isCorrect == true);
  final motif = switch (step.visual) {
    LostMissionVisual.square => LostSceneMotif.square,
    LostMissionVisual.look ||
    LostMissionVisual.meetingPoint => LostSceneMotif.landmark,
    LostMissionVisual.helper ||
    LostMissionVisual.waiting => LostSceneMotif.helper,
    LostMissionVisual.stranger => LostSceneMotif.stranger,
    LostMissionVisual.contacts ||
    LostMissionVisual.calling => LostSceneMotif.phone,
    LostMissionVisual.reunion => LostSceneMotif.family,
    LostMissionVisual.confirmation => LostSceneMotif.safe,
    LostMissionVisual.recall => LostSceneMotif.recall,
  };
  return LostMissionSceneLayout(
    motif: motif,
    description: switch (motif) {
      LostSceneMotif.square => 'A child stops in a fictional public square.',
      LostSceneMotif.landmark =>
        'Practice landmark: ${context.meetingPointLabel}. '
            '${resolveLostLandmark(context.meetingPoint.presetId).description} '
            '${arriving ? 'The child moves nearby in the story.' : 'Remember its picture.'}',
      LostSceneMotif.helper =>
        'A child stays near a visible public help desk in the story.',
      LostSceneMotif.stranger => 'An unknown person offers to leave. The child stays in the public place.',
      LostSceneMotif.phone => 'A pretend family call. No real call is made.',
      LostSceneMotif.family => 'The child and parent reunite in the story.',
      LostSceneMotif.safe => 'Pretend safety confirmation. No message is sent.',
      LostSceneMotif.recall => 'Stop. Look. Meeting point if nearby. Ask for help. Family. Wait. I am safe.',
    },
    childPose: arriving ? ChildPoseName.walk : ChildPoseName.stand,
    childAtMeetingPoint: arriving,
  );
}
