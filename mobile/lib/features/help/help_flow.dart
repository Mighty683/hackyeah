/// Offline orientation content, not medical triage or reviewed safety advice.
/// Source passages and release limitations are recorded in docs/EMERGENCY_HELP.md.
enum HelpPage {
  helpers,
  checkHelper,
  withHelper,
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

  /// Offered only after no helper is confirmed and phone service is reported.
  final bool offerEmergency;
}

const helpSteps = <HelpPage, HelpStep>{
  HelpPage.helpers: HelpStep(
    title: 'Can someone nearby help you?',
    note: 'A trusted adult, police officer or shop worker.',
    choices: [
      HelpChoice('Yes', HelpPage.withHelper),
      HelpChoice('No one can help', HelpPage.situations),
      HelpChoice('I’m not sure', HelpPage.checkHelper),
    ],
  ),
  HelpPage.checkHelper: HelpStep(
    title: 'Is a trusted adult or helper already nearby?',
    note: 'You do not need to walk around to answer.',
    choices: [
      HelpChoice('Someone can help', HelpPage.withHelper),
      HelpChoice('No one can help', HelpPage.situations),
    ],
  ),
  HelpPage.withHelper: HelpStep(
    title: 'Tell that adult what happened.',
    note: 'Do not leave with someone you do not know.',
    choices: [HelpChoice('They cannot help', HelpPage.situations)],
  ),
  HelpPage.situations: HelpStep(
    title: 'What is happening?',
    choices: [
      HelpChoice('Someone is not responding', HelpPage.unresponsive),
      HelpChoice('Air raid', HelpPage.airLocation),
      HelpChoice('I am lost', HelpPage.lostNoAdult),
      HelpChoice('I don’t know', HelpPage.unsure),
    ],
  ),
  HelpPage.unresponsive: HelpStep(
    title: 'Call 112 now.',
    note: 'Do not wait for a parent to answer.',
    urgent: true,
    offerEmergency: true,
    choices: [HelpChoice('Practise the next step', HelpPage.operator)],
  ),
  HelpPage.unresponsiveOffline: HelpStep(
    title: 'Shout for an adult’s help.',
    note:
        'Do not approach if the place is dangerous. '
        'This app cannot provide complete first-aid instructions.',
    urgent: true,
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
  HelpPage.lostNoAdult: HelpStep(
    title: 'Stay here unless there is danger.',
    note: 'Do not leave with someone you do not know.',
    offerContact: true,
    offerEmergency: true,
  ),
  HelpPage.unsure: HelpStep(
    title: 'Call out for an adult’s help.',
    note: 'You do not need to investigate what happened.',
    offerContact: true,
    offerEmergency: true,
  ),
};
