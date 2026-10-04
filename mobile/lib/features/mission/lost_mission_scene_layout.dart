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
      LostSceneMotif.square =>
        'Dziecko zatrzymuje się na fikcyjnym placu publicznym.',
      LostSceneMotif.landmark =>
        'Punkt orientacyjny do ćwiczeń: ${context.meetingPointLabel}. '
            '${context.photoMeetingPoint == null ? resolveLostLandmark(context.meetingPoint.presetId).description : 'Zapisane zdjęcie miejsca spotkania.'} '
            '${arriving ? 'W tej historii dziecko podchodzi bliżej.' : 'Zapamiętaj ten obrazek.'}',
      LostSceneMotif.helper =>
        'W tej historii dziecko zostaje przy widocznym punkcie pomocy.',
      LostSceneMotif.stranger => 'Nieznajoma osoba proponuje odejście. Dziecko zostaje w miejscu publicznym.',
      LostSceneMotif.phone =>
        'Połączenie do rodziny na niby. Bez prawdziwego połączenia.',
      LostSceneMotif.family => 'W tej historii dziecko i rodzic znów są razem.',
      LostSceneMotif.safe => 'Potwierdzenie bezpieczeństwa na niby. Żadna wiadomość nie jest wysyłana.',
      LostSceneMotif.recall => 'Zatrzymaj się. Spójrz. Punkt spotkania, jeśli blisko. Poproś o pomoc. Rodzina. Czekaj. Jestem w bezpiecznym miejscu.',
    },
    childPose: arriving ? ChildPoseName.walk : ChildPoseName.stand,
    childAtMeetingPoint: arriving,
  );
}
