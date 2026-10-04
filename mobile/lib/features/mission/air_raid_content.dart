import 'air_raid_models.dart';

/// Keep the interruption tied to the destination the child just chose.
MissionStep outdoorNoiseStep(String? destination) => MissionStep(
  id: 'outdoor_noise',
  title: 'Nadal na zewnątrz',
  narration: switch (destination) {
    'home' => 'Idziesz w stronę domu. Zanim dotrzesz, słyszysz głośny huk.',
    'school' => 'Idziesz w stronę szkoły. Zanim dotrzesz, słyszysz głośny huk.',
    'park' => 'Jesteś przy otwartym parku. Nagle słyszysz głośny huk.',
    'bus_stop' => 'Jesteś przy przystanku. Nagle słyszysz głośny huk.',
    _ => 'Zanim dotrzesz do schronienia, słyszysz głośny huk.',
  },
  visual: MissionVisual.getDown,
  sound: 'noise',
);

Map<String, MissionStep> buildAirRaidSteps(MissionMode mode) {
  final stayInside = mode == MissionMode.home
      ? 'Zostań w domu.'
      : 'Zostań w schronieniu.';
  final steps = <MissionStep>[
    const MissionStep(
      id: 'alarm',
      title: 'Alarm w domu',
      narration:
          'To alarm. W tym ćwiczeniu nie możesz dotrzeć do schronienia. '
          'Znajdź bezpieczniejsze miejsce w domu, z dala od okien.',
      visual: MissionVisual.alarm,
      sound: 'alarm',
    ),
    MissionStep(
      id: 'room',
      title: 'Dokąd pójdziesz?',
      narration: 'Rozpoczął się alarm. Co zrobisz?',
      visual: MissionVisual.room,
      choices: [
        _choice(
          'window',
          'Podejdź do okna',
          MissionActionIcon.window,
          false,
          'Przy oknach jest mniej bezpiecznie. Odsuń się od nich.',
        ),
        _choice(
          'door',
          'Wyjdź na zewnątrz',
          MissionActionIcon.door,
          false,
          'W tym ćwiczeniu zostań w środku i znajdź bezpieczniejsze miejsce.',
        ),
        _choice(
          'interior',
          'Przejdź w głąb domu',
          MissionActionIcon.interior,
          true,
          'Dobrze. Jesteś teraz dalej od okien.',
        ),
      ],
    ),
    MissionStep(
      id: 'apartment',
      title: 'Wybierz pomieszczenie',
      narration: 'Znajdź miejsce z dala od okien.',
      visual: MissionVisual.apartment,
      choices: [
        _choice(
          'living_room',
          'Salon',
          MissionActionIcon.livingRoom,
          false,
          'Tu jest okno. Znajdź miejsce dalej w środku.',
        ),
        _choice(
          'bedroom',
          'Sypialnia',
          MissionActionIcon.bedroom,
          false,
          'Tu jest okno. Znajdź miejsce dalej w środku.',
        ),
        _choice(
          'kitchen',
          'Kuchnia',
          MissionActionIcon.kitchen,
          false,
          'Tu jest okno. Znajdź miejsce dalej w środku.',
        ),
        _choice(
          'hallway',
          'Wewnętrzny korytarz',
          MissionActionIcon.hallway,
          true,
          'Dwie ściany pomagają cię chronić.',
          visual: MissionVisual.twoWalls,
        ),
      ],
    ),
    MissionStep(
      id: 'contacts',
      title: 'Powiedz zaufanej osobie dorosłej',
      narration: 'Jesteś z dala od okien. Wybierz zaufaną osobę dorosłą.',
      visual: MissionVisual.contacts,
      choices: [
        _choice(
          'mom',
          'Mama',
          MissionActionIcon.mom,
          true,
          'Powiedz mamie, gdzie jesteś. To na niby.',
        ),
        _choice(
          'dad',
          'Tata',
          MissionActionIcon.dad,
          true,
          'Powiedz tacie, gdzie jesteś. To na niby.',
        ),
        _choice(
          'grandparent',
          'Babcia lub dziadek',
          MissionActionIcon.grandparent,
          true,
          'Powiedz babci lub dziadkowi, gdzie jesteś. To na niby.',
        ),
      ],
    ),
    MissionStep(
      id: 'communication',
      title: 'Najpierw spróbuj zadzwonić raz',
      narration: 'Spróbuj raz zadzwonić na niby do zaufanej osoby dorosłej.',
      visual: MissionVisual.communication,
      choices: [
        _choice(
          'call',
          'Spróbuj zadzwonić raz',
          MissionActionIcon.call,
          true,
          'W tym ćwiczeniu nikt nie odbiera. Spróbuj wysłać krótki SMS.',
        ),
      ],
    ),
    MissionStep(
      id: 'sms',
      title: 'Nikt nie odbiera? Wyślij SMS',
      narration: 'Nikt nie odebrał. Wyślij jeden krótki SMS z informacją, gdzie jesteś.',
      visual: MissionVisual.communication,
      choices: [
        _choice(
          'message',
          'Wyślij SMS',
          MissionActionIcon.message,
          true,
          'Twoja wiadomość na niby: Jestem z dala od okien.',
        ),
      ],
    ),
    const MissionStep(
      id: 'message',
      title: 'Odpowiedź na niby',
      narration:
          'Twoja wiadomość: Jestem z dala od okien. '
          'Zaufana osoba dorosła odpowiada: Dobrze. Zostań tam i czekaj na odwołanie alarmu.',
      visual: MissionVisual.message,
    ),
    MissionStep(
      id: 'noise',
      title: 'Słyszysz głośny huk',
      narration: 'Słyszysz głośny huk. Co zrobisz?',
      visual: MissionVisual.sheltered,
      sound: 'noise',
      choices: [
        _choice(
          'window',
          'Podejdź do okna',
          MissionActionIcon.window,
          false,
          'Nie podchodź jeszcze do okna. Zostań z dala od okien.',
        ),
        _choice(
          'door',
          'Podejdź do drzwi',
          MissionActionIcon.door,
          false,
          'Jeszcze nie wychodź. Zostań w osłoniętym miejscu.',
        ),
        _choice(
          'stay',
          'Zostań tutaj',
          MissionActionIcon.stay,
          true,
          'Dobrze. Zostań tutaj.',
        ),
      ],
    ),
    MissionStep(
      id: 'quiet',
      title: 'Teraz jest cicho',
      narration: 'Teraz jest cicho. Co zrobisz?',
      visual: MissionVisual.quiet,
      choices: [
        _choice(
          'leave',
          'Wyjdź teraz',
          MissionActionIcon.leave,
          false,
          'Cisza nie oznacza końca zagrożenia. '
              '$stayInside '
              'Czekaj na odwołanie alarmu.',
        ),
        _choice(
          'stay',
          'Zostań i czekaj',
          MissionActionIcon.stay,
          true,
          'Dobrze. $stayInside Czekaj na odwołanie alarmu.',
        ),
      ],
    ),
    const MissionStep(
      id: 'all_clear',
      title: 'Odwołanie alarmu',
      narration:
          'W tym ćwiczeniu alarm zostaje oficjalnie odwołany. '
          'Teraz stosuj się do poleceń dorosłych lub służb ratunkowych.',
      visual: MissionVisual.allClear,
      sound: 'all_clear',
    ),
    MissionStep(
      id: 'recall',
      title: 'Ćwiczenie ukończone',
      narration: AirRaidPracticeRecap.narration,
      visual: MissionVisual.recall,
    ),
    const MissionStep(
      id: 'outdoor_alarm',
      title: 'Alarm podczas spaceru',
      narration: 'Na tej ulicy na niby słyszysz alarm.',
      visual: MissionVisual.street,
      sound: 'alarm',
    ),
    MissionStep(
      id: 'destination',
      title: 'Dokąd pójdziesz?',
      narration: 'Słyszysz alarm. Wybierz, dokąd pójdziesz.',
      visual: MissionVisual.street,
      choices: [
        _choice(
          'home',
          'Dom: daleko',
          MissionActionIcon.home,
          false,
          'Dom jest za daleko. Nadal jesteś na zewnątrz.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'school',
          'Szkoła: jeszcze dalej',
          MissionActionIcon.school,
          false,
          'Szkoła jest za daleko. Nadal jesteś na zewnątrz.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'shelter',
          'Bliskie, solidne schronienie',
          MissionActionIcon.shelter,
          true,
          'Jesteś w pobliskim schronieniu na niby, z dala od okien.',
        ),
        _choice(
          'more_places',
          'Spójrz na inne miejsca',
          MissionActionIcon.next,
          true,
          'Spójrz na park, przystanek i pobliskie schronienie.',
        ),
      ],
    ),
    MissionStep(
      id: 'outdoor_places',
      title: 'Wybierz pobliskie miejsce',
      narration: 'Które pobliskie miejsce wybierzesz?',
      visual: MissionVisual.street,
      choices: [
        _choice(
          'park',
          'Park',
          MissionActionIcon.park,
          false,
          'Otwarty park słabo chroni. Nadal jesteś na zewnątrz.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'bus_stop',
          'Przystanek',
          MissionActionIcon.busStop,
          false,
          'Przystanek słabo chroni. Nadal jesteś na zewnątrz.',
          continuesAfterFeedback: true,
        ),
        _choice(
          'shelter',
          'Bliskie, solidne schronienie',
          MissionActionIcon.shelter,
          true,
          'Jesteś w pobliskim schronieniu na niby, z dala od okien.',
        ),
      ],
    ),
    MissionStep(
      id: 'get_down',
      title: 'Co zrobisz?',
      narration: 'Huk zaczyna się, gdy nadal jesteś na zewnątrz.',
      visual: MissionVisual.getDown,
      choices: [
        _choice(
          'stay',
          'Stój dalej',
          MissionActionIcon.stay,
          false,
          'Połóż się, aby być niżej.',
        ),
        _choice(
          'down',
          'Połóż się',
          MissionActionIcon.down,
          true,
          'Jesteś nisko. Teraz chroń głowę.',
        ),
      ],
    ),
    MissionStep(
      id: 'protect_head',
      title: 'Chroń głowę',
      narration: 'Zostań nisko i chroń głowę.',
      visual: MissionVisual.protectHead,
      choices: [
        _choice(
          'stay',
          'Zostaw ręce opuszczone',
          MissionActionIcon.stay,
          false,
          'Osłoń głowę rękami.',
        ),
        _choice(
          'protect_head',
          'Osłoń głowę',
          MissionActionIcon.protectHead,
          true,
          'Dobrze. Zostań nisko z osłoniętą głową.',
        ),
      ],
    ),
    const MissionStep(
      id: 'outdoor_recover',
      title: 'Dorosły pomaga ci',
      narration:
          'Zostajesz nisko z osłoniętą głową. W tej historii zaufana osoba dorosła '
          'pomaga ci dotrzeć do schronienia, gdy jest to możliwe.',
      visual: MissionVisual.protectHead,
    ),
    const MissionStep(
      id: 'outdoor_sheltered',
      title: 'W schronieniu na niby',
      narration: 'Jesteś teraz w schronieniu na niby, z dala od okien.',
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
