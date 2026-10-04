import 'data/lost_practice_context.dart';
import 'lost_landmarks.dart';
import 'lost_mission_models.dart';

Map<String, LostMissionStep> buildLostMissionSteps(
  LostPracticeContext context,
  LostPracticeVariant variant,
) {
  final landmark = resolveLostLandmark(context.meetingPoint.presetId);
  final otherLandmark = resolveLostLandmark(
    landmark.id == 'fountain' ? 'information_desk' : 'fountain',
  );
  final photoTarget = context.photoMeetingPoint;
  final photoChoices = photoTarget == null
      ? <LostMissionChoice>[]
      : _photoChoices(context, photoTarget);
  final steps = <LostMissionStep>[
    LostMissionStep(
      id: 'stop',
      title: 'Nie widzisz rodzica',
      narration: 'Nie widzisz rodzica. Co zrobisz?',
      visual: LostMissionVisual.square,
      choices: [
        _choice(
          'search',
          'Biegnij i szukaj',
          LostActionIcon.search,
          false,
          'Gdy odbiegniesz, trudniej cię znaleźć. Najpierw się zatrzymaj.',
        ),
        _choice(
          'leave',
          'Opuść to miejsce',
          LostActionIcon.leave,
          false,
          'Rodzic może szukać cię tutaj. Zatrzymaj się i rozejrzyj.',
        ),
        _choice(
          'stop',
          'Zatrzymaj się i spójrz',
          LostActionIcon.stop,
          true,
          'Dobrze. Teraz stoisz. Rozejrzyj się.',
        ),
      ],
    ),
    LostMissionStep(
      id: 'look',
      title: 'Przypomnij sobie miejsce spotkania',
      narration:
          'Rozejrzyj się. Twoje miejsce spotkania do ćwiczeń to '
          '${context.meetingPointLabel}.',
      visual: LostMissionVisual.look,
      actionLabel: variant == LostPracticeVariant.meetingPointNearby
          ? 'Znajdź miejsce spotkania'
          : 'Poszukaj pomocy w pobliżu',
    ),
    LostMissionStep(
      id: 'meeting_point',
      title: 'Które to twoje miejsce spotkania?',
      narration: 'Widzisz miejsce spotkania w pobliżu. Wybierz je.',
      visual: LostMissionVisual.meetingPoint,
      choices: [
        if (photoTarget != null)
          ...photoChoices
        else ...[
          LostMissionChoice(
            id: landmark.id,
            label: context.meetingPointLabel,
            icon: LostActionIcon.meetingPoint,
            isCorrect: true,
            feedback:
                'Tak. Rozpoznajesz pobliskie miejsce spotkania do ćwiczeń.',
            landmarkPresetId: landmark.id,
          ),
          LostMissionChoice(
            id: otherLandmark.id,
            label: otherLandmark.label,
            icon: LostActionIcon.meetingPoint,
            isCorrect: false,
            feedback: 'To inny punkt orientacyjny. Przypomnij sobie miejsce spotkania.',
            landmarkPresetId: otherLandmark.id,
          ),
        ],
        _choice(
          'leave',
          'Idź do wyjścia',
          LostActionIcon.leave,
          false,
          'Gdy odejdziesz, trudniej cię znaleźć. Wybierz pobliskie miejsce spotkania.',
        ),
      ],
    ),
    if (photoTarget != null)
      LostMissionStep(
        id: 'map_meeting_point',
        title: 'Znajdź miejsce spotkania na Naszej mapie',
        narration:
            'Znajdź ${context.meetingPointLabel}. Dotknij znacznika ze zdjęciem. '
            'Przesuwaj mapę. Zbliżaj palcami. To tylko ćwiczenie z mapą.',
        visual: LostMissionVisual.meetingPoint,
        choices: [
          if (context.homePoint case final home?)
            LostMissionChoice(
              id: LostPracticeHomePoint.id,
              label: home.label,
              icon: LostActionIcon.meetingPoint,
              isCorrect: false,
              feedback:
                  'Dom to inne miejsce. Poszukaj zdjęcia miejsca spotkania.',
            ),
          for (final choice in photoChoices.where(
            (choice) => choice.photoPath != null,
          ))
            LostMissionChoice(
              id: choice.id,
              label: choice.label,
              icon: choice.icon,
              isCorrect: choice.isCorrect,
              photoPath: choice.photoPath,
              isDemoPhoto: choice.isDemoPhoto,
              feedback: choice.isCorrect
                  ? 'Tak. Ten znacznik wskazuje ${context.meetingPointLabel}. '
                        'To miejsce znalezione na mapie. Jeszcze tam nie jesteś.'
                  : 'Ten znacznik wskazuje inne miejsce. Poszukaj zdjęcia miejsca spotkania.',
            ),
        ],
      ),
    LostMissionStep(
      id: 'arrive',
      title: 'W miejscu spotkania na niby',
      narration:
          'W tej historii docierasz do miejsca: ${context.meetingPointLabel}. '
          'Pracownicy w pobliżu mogą pomóc.',
      visual: LostMissionVisual.meetingPoint,
      actionLabel: 'Poproś o pomoc w pobliżu',
    ),
    LostMissionStep(
      id: 'point_unavailable',
      title: 'Nie widzisz miejsca spotkania',
      narration: 'Nie widzisz miejsca spotkania. Co zrobisz?',
      visual: LostMissionVisual.square,
      choices: [
        _choice(
          'leave',
          'Idź nieznanymi ulicami',
          LostActionIcon.leave,
          false,
          'Na nieznanych ulicach trudniej się odnaleźć. Zostań w pobliżu.',
        ),
        _choice(
          'search',
          'Szukaj dalej samodzielnie',
          LostActionIcon.search,
          false,
          'Gdy szukasz samodzielnie, trudniej cię znaleźć. Zapytaj pracownika w pobliżu.',
        ),
        _choice(
          'stay',
          'Zostań blisko i poproś o pomoc',
          LostActionIcon.stay,
          true,
          'Dobrze. Zostań blisko. Poszukaj pomocy w punkcie informacji.',
        ),
      ],
    ),
    LostMissionStep(
      id: 'helper',
      title: 'Kto może tutaj pomóc?',
      narration: 'Szukaj pomocy tutaj, gdzie inni cię widzą.',
      visual: LostMissionVisual.helper,
      choices: [
        _choice(
          'staff',
          'Zapytaj pracownika w punkcie informacji',
          LostActionIcon.staff,
          true,
          'Poproś pracownika o kontakt z rodziną. Zostań przy punkcie informacji.',
        ),
        _choice(
          'unknown_adult',
          'Odejdź za kimś',
          LostActionIcon.unknownAdult,
          false,
          'W nieznanym miejscu trudniej cię znaleźć. Poproś o pomoc tutaj.',
        ),
        _choice(
          'search',
          'Szukaj dalej samodzielnie',
          LostActionIcon.search,
          false,
          'Gdy szukasz samodzielnie, trudniej cię znaleźć. Poproś o pomoc tutaj.',
        ),
      ],
    ),
    LostMissionStep(
      id: 'stranger',
      title: 'Ktoś prosi, by za nim pójść',
      narration: 'Ktoś mówi: Chodź ze mną, znajdziemy twojego rodzica.',
      visual: LostMissionVisual.stranger,
      choices: [
        _choice(
          'leave',
          'Idź z tą osobą',
          LostActionIcon.leave,
          false,
          'Zostań tam, gdzie można cię znaleźć. Poproś pracownika o kontakt z rodziną.',
        ),
        _choice(
          'stay',
          'Zostań tutaj i zapytaj pracownika',
          LostActionIcon.stay,
          true,
          'Dobrze. Zostajesz tutaj i prosisz pracownika o kontakt z rodziną.',
        ),
      ],
    ),
    LostMissionStep(
      id: 'contact',
      title: 'Zadzwoń do rodziny na niby',
      narration: 'Wybierz zaufaną osobę. To połączenie na niby.',
      visual: LostMissionVisual.contacts,
      choices: context.contacts.map(_contactChoice).toList(growable: false),
    ),
    const LostMissionStep(
      id: 'reply',
      title: 'Odpowiedź na niby',
      narration:
          'W tej historii rodzina wie, gdzie jesteś. '
          'Pracownicy zostają z tobą.',
      visual: LostMissionVisual.calling,
      actionLabel: 'Zostań z pracownikami',
    ),
    LostMissionStep(
      id: 'wait',
      title: 'Rodzic jest w drodze',
      narration: 'W tej historii rodzic jest w drodze. Co zrobisz?',
      visual: LostMissionVisual.waiting,
      choices: [
        _choice(
          'leave',
          'Odejdź i szukaj',
          LostActionIcon.leave,
          false,
          'Rodzina zna to miejsce. Zostań tutaj, aby mogli cię znaleźć.',
        ),
        _choice(
          'stay',
          'Zostań tutaj i czekaj',
          LostActionIcon.wait,
          true,
          'Dobrze. Zostań z pracownikami. Rodzic jest w drodze.',
        ),
      ],
    ),
    const LostMissionStep(
      id: 'reunion',
      title: 'Rodzic przychodzi',
      narration: 'W tej historii rodzic przychodzi. Znów jesteście razem.',
      visual: LostMissionVisual.reunion,
      actionLabel: 'Powiedz Jestem w bezpiecznym miejscu',
    ),
    const LostMissionStep(
      id: 'confirm_safe',
      title: 'Znów jesteście razem',
      narration: 'Dotknij Jestem w bezpiecznym miejscu. To tylko ćwiczenie.',
      visual: LostMissionVisual.reunion,
      actionLabel: "JESTEM W BEZPIECZNYM MIEJSCU",
    ),
    const LostMissionStep(
      id: 'confirmation',
      title: 'Potwierdzenie na niby',
      narration: 'Ćwiczenie ukończone. Nie wysłano żadnej wiadomości.',
      visual: LostMissionVisual.confirmation,
      actionLabel: 'Zapamiętaj kroki',
    ),
    LostMissionStep(
      id: 'recall',
      title: 'Zapamiętaj ćwiczone kroki',
      narration: LostPracticeRecap.narration,
      visual: LostMissionVisual.recall,
      actionLabel: 'Zakończ ćwiczenie',
    ),
  ];
  return {for (final step in steps) step.id: step};
}

List<LostMissionChoice> _photoChoices(
  LostPracticeContext context,
  LostPracticePlace target,
) {
  final others =
      context.photoPlaces.where((place) => place.id != target.id).toList()
        ..shuffle();
  final choices = [
    for (final place in [target, ...others.take(2)])
      LostMissionChoice(
        id: place.id,
        label: place.label,
        icon: LostActionIcon.meetingPoint,
        isCorrect: place.id == target.id,
        photoPath: place.photoPath,
        isDemoPhoto: place.isDemo,
        feedback: place.id == target.id
            ? 'Tak. To twoje miejsce spotkania: ${target.label}.'
            : 'To inne miejsce. Spójrz ponownie na zdjęcie miejsca spotkania.',
      ),
    if (others.isEmpty)
      LostMissionChoice(
        id: 'different-landmark',
        label: 'Inny punkt informacji',
        icon: LostActionIcon.meetingPoint,
        isCorrect: false,
        landmarkPresetId: 'information_desk',
        feedback: 'To obrazek na niby. Poszukaj zapisanego zdjęcia miejsca spotkania.',
      ),
  ]..shuffle();
  return choices;
}

LostMissionStep lostNoAnswerStep(
  LostPracticeContext context,
  String? firstContactId,
) => LostMissionStep(
  id: 'no_answer',
  title: 'Nikt nie odbiera połączenia na niby',
  narration:
      'Zostań z pracownikami. Spróbuj skontaktować się z inną zaufaną osobą.',
  visual: LostMissionVisual.contacts,
  choices: [
    for (final contact in context.contacts)
      if (contact.id != firstContactId) _contactChoice(contact),
    _choice(
      'leave',
      'Odejdź i szukaj',
      LostActionIcon.leave,
      false,
      'Zostań z pracownikami. Spróbuj tutaj skontaktować się z inną zaufaną osobą.',
    ),
  ],
);

LostMissionChoice _contactChoice(
  LostPracticeContact contact,
) => LostMissionChoice(
  id: contact.id,
  label: 'Połączenie na niby: ${contact.label}',
  icon: switch (contact.avatar) {
    LostContactAvatar.mother => LostActionIcon.mother,
    LostContactAvatar.father => LostActionIcon.father,
    LostContactAvatar.grandparent => LostActionIcon.grandparent,
    LostContactAvatar.adult => LostActionIcon.adult,
  },
  isCorrect: true,
  feedback: contact.isFictional
      ? 'Wybrana osoba: ${contact.label}. To fikcyjna osoba i połączenie na niby.'
      : 'Wybrana osoba: ${contact.label}. To połączenie na niby.',
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
