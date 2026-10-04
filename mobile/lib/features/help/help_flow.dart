/// Offline orientation content, not medical triage or reviewed safety advice.
/// Source passages and release limitations are recorded in docs/EMERGENCY_HELP.md.
enum HelpPage {
  withHelper,
  situations,
  unresponsive,
  operator,
  airLocation,
  airInside,
  airOutside,
  airExplosion,
  airUnknown,
  airStairs,
  airStay,
  airBlocked,
  lostNoAdult,
  unsure,
}

class HelpChoice {
  const HelpChoice(this.label, this.next);

  final String label;
  final HelpPage next;
}

class HelpStep {
  const HelpStep({
    required this.title,
    this.note,
    this.choices = const [],
    this.urgent = false,
    this.offerContact = false,
    this.offerEmergency = false,
  });

  final String title;
  final String? note;
  final List<HelpChoice> choices;
  final bool urgent;
  final bool offerContact;

  /// Offline pretend-call action; never depends on telephone service.
  final bool offerEmergency;
}

const helpSteps = <HelpPage, HelpStep>{
  HelpPage.withHelper: HelpStep(
    title: 'Powiedz tej osobie dorosłej, co się stało.',
    note: 'Nie odchodź z osobą, której nie znasz.',
  ),
  HelpPage.situations: HelpStep(
    title: 'Co się dzieje?',
    choices: [
      HelpChoice('Ktoś nie reaguje', HelpPage.unresponsive),
      HelpChoice('Alarm lotniczy', HelpPage.airLocation),
      HelpChoice('Nie wiem, gdzie jestem', HelpPage.lostNoAdult),
      HelpChoice('Nie wiem', HelpPage.unsure),
    ],
  ),
  HelpPage.unresponsive: HelpStep(
    title: 'Przećwicz telefon pod 112.',
    note: 'Nie czekaj, aż rodzic odbierze.',
    urgent: true,
    offerEmergency: true,
    choices: [HelpChoice('Przećwicz następny krok', HelpPage.operator)],
  ),
  HelpPage.operator: HelpStep(
    title: 'Wykonuj polecenia operatora numeru alarmowego.',
    note: 'Nie rozłączaj się, dopóki operator na to nie pozwoli.',
    urgent: true,
  ),
  HelpPage.airLocation: HelpStep(
    title: 'Gdzie teraz jesteś?',
    choices: [
      HelpChoice('W budynku', HelpPage.airInside),
      HelpChoice('Na zewnątrz, nie słychać wybuchów', HelpPage.airOutside),
      HelpChoice('Na zewnątrz, słychać wybuchy', HelpPage.airExplosion),
      HelpChoice('Nie wiem', HelpPage.airUnknown),
    ],
  ),
  HelpPage.airInside: HelpStep(
    title: 'Zostań z dala od okien.',
    choices: [HelpChoice('Przeczytaj krok o schronieniu', HelpPage.airStairs)],
  ),
  HelpPage.airOutside: HelpStep(
    title: 'Skorzystaj z pobliskiego schronienia, jeśli możesz tam dotrzeć.',
    note:
        'Oficjalne zalecenia wymieniają piwnice i przejścia podziemne. '
        'Aplikacja nie ma zweryfikowanej mapy schronień.',
    choices: [
      HelpChoice('Jestem w schronieniu', HelpPage.airStay),
      HelpChoice('Nie mogę dotrzeć do schronienia', HelpPage.airBlocked),
    ],
  ),
  HelpPage.airExplosion: HelpStep(
    title: 'Połóż się i osłoń głowę.',
    note:
        'Przy wybuchach na zewnątrz skorzystaj z zagłębienia terenu, '
        'jeśli jest w zasięgu.',
  ),
  HelpPage.airUnknown: HelpStep(
    title: 'Poproś zaufaną osobę dorosłą o pomoc w znalezieniu schronienia.',
    choices: [
      HelpChoice('Jestem w schronieniu', HelpPage.airStay),
      HelpChoice('Żaden dorosły nie może pomóc', HelpPage.airBlocked),
    ],
  ),
  HelpPage.airStairs: HelpStep(
    title: 'Skorzystaj z ustalonej drogi do schronienia, jeśli ją znasz.',
    note:
        'Korzystaj ze schodów, nie z windy. Baza z gry nie jest schronieniem.',
    choices: [
      HelpChoice('Jestem w schronieniu', HelpPage.airStay),
      HelpChoice('Nie znam drogi', HelpPage.airBlocked),
      HelpChoice('Nie mogę dotrzeć do schronienia', HelpPage.airBlocked),
    ],
  ),
  HelpPage.airBlocked: HelpStep(
    title: 'Stosuj się do oficjalnych poleceń.',
    note:
        'To ćwiczenie nie znajdzie bezpiecznej drogi do schronienia. '
        'Jeśli zaufana osoba dorosła jest blisko, poproś ją o pomoc.',
    choices: [
      HelpChoice('Wybierz moją pozycję ponownie', HelpPage.airLocation),
    ],
  ),
  HelpPage.airStay: HelpStep(
    title: 'Zostań w schronieniu i stosuj się do oficjalnych poleceń.',
  ),
  HelpPage.lostNoAdult: HelpStep(
    title: 'Zostań tutaj, chyba że jest niebezpiecznie.',
    note: 'Nie odchodź z osobą, której nie znasz.',
    offerContact: true,
    offerEmergency: true,
  ),
  HelpPage.unsure: HelpStep(
    title: 'Zawołaj dorosłego na pomoc.',
    note: 'Nie musisz sprawdzać, co się stało.',
    offerContact: true,
    offerEmergency: true,
  ),
};
