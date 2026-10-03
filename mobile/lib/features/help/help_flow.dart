/// Offline orientation content, not medical triage or reviewed safety advice.
/// Source passages and release limitations are recorded in docs/EMERGENCY_HELP.md.
enum HelpPage {
  situations,
  unresponsive,
  unresponsiveOffline,
  operator,
  airLocation,
  airInside,
  airOutside,
  airExplosion,
  airUnknown,
  airStairs,
  airStay,
  lostAdult,
  lostStay,
  lostNearby,
  lostStaff,
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
  });

  final String title;
  final String? note;
  final List<HelpChoice> choices;
  final bool urgent;
  final bool offerContact;
}

const helpSteps = <HelpPage, HelpStep>{
  HelpPage.situations: HelpStep(
    title: 'What is happening?',
    choices: [
      HelpChoice('Someone is not responding', HelpPage.unresponsive),
      HelpChoice('Air raid', HelpPage.airLocation),
      HelpChoice('I am lost', HelpPage.lostAdult),
      HelpChoice('I don’t know', HelpPage.unsure),
    ],
  ),
  HelpPage.unresponsive: HelpStep(
    title: 'Call 112 now.',
    note: 'Do not wait for a parent to answer.',
    urgent: true,
    choices: [
      HelpChoice('No phone signal', HelpPage.unresponsiveOffline),
      HelpChoice('The call connected', HelpPage.operator),
    ],
  ),
  HelpPage.unresponsiveOffline: HelpStep(
    title: 'Shout for an adult’s help.',
    note:
        'Do not approach if the place is dangerous. '
        'This app cannot provide complete first-aid instructions.',
    urgent: true,
    choices: [HelpChoice('Try the phone again', HelpPage.unresponsive)],
  ),
  HelpPage.operator: HelpStep(
    title: 'Follow the emergency operator’s instructions.',
    note: 'Stay on the call until they tell you to stop.',
    urgent: true,
  ),
  HelpPage.airLocation: HelpStep(
    title: 'Where are you now?',
    choices: [
      HelpChoice('Inside a building', HelpPage.airInside),
      HelpChoice('Outside', HelpPage.airOutside),
      HelpChoice('Outside, hearing explosions', HelpPage.airExplosion),
      HelpChoice('I don’t know', HelpPage.airUnknown),
    ],
  ),
  HelpPage.airInside: HelpStep(
    title: 'Stay away from windows.',
    choices: [HelpChoice('Read the shelter step', HelpPage.airStairs)],
  ),
  HelpPage.airOutside: HelpStep(
    title: 'Use nearby shelter if you can reach it.',
    note:
        'Official guidance lists basements and underground passages. '
        'This app has no verified shelter map.',
    choices: [HelpChoice('I reached shelter', HelpPage.airStay)],
  ),
  HelpPage.airExplosion: HelpStep(
    title: 'Lie down and cover your head.',
    note:
        'For explosions while outside, use a dip in the ground '
        'if one is within reach.',
  ),
  HelpPage.airUnknown: HelpStep(
    title: 'Ask a trusted adult to help you find shelter.',
    choices: [HelpChoice('I reached shelter', HelpPage.airStay)],
  ),
  HelpPage.airStairs: HelpStep(
    title: 'Use your agreed shelter route, if you know it.',
    note: 'Use stairs, not lifts. The game’s base is not a shelter.',
    choices: [HelpChoice('I reached shelter', HelpPage.airStay)],
  ),
  HelpPage.airStay: HelpStep(
    title: 'Stay in shelter and follow official instructions.',
  ),
  HelpPage.lostAdult: HelpStep(
    title: 'Is a trusted adult with you?',
    choices: [
      HelpChoice('Yes', HelpPage.lostStaff),
      HelpChoice('No', HelpPage.lostStay),
      HelpChoice('I don’t know', HelpPage.lostStay),
    ],
    offerContact: true,
  ),
  HelpPage.lostStay: HelpStep(
    title: 'Stay where you are, unless there is danger.',
    note: 'Do not leave with someone you do not know.',
    choices: [HelpChoice('Look at nearby helpers', HelpPage.lostNearby)],
    offerContact: true,
  ),
  HelpPage.lostNearby: HelpStep(
    title: 'Who is already nearby?',
    note: 'You do not need to walk around to answer.',
    choices: [
      HelpChoice('Police officer or shop worker', HelpPage.lostStaff),
      HelpChoice('No one', HelpPage.lostNoAdult),
      HelpChoice('I don’t know', HelpPage.lostNoAdult),
    ],
    offerContact: true,
  ),
  HelpPage.lostStaff: HelpStep(
    title: 'Ask that adult to help contact your family.',
    note: 'Do not leave with someone you do not know.',
    offerContact: true,
  ),
  HelpPage.lostNoAdult: HelpStep(
    title: 'Stay here unless there is danger.',
    note:
        'Without phone service, stay where you are unless there is danger. '
        'Do not leave with someone you do not know.',
    offerContact: true,
  ),
  HelpPage.unsure: HelpStep(
    title: 'Ask a trusted adult nearby for help.',
    note: 'You do not need to investigate what happened.',
    offerContact: true,
  ),
};
