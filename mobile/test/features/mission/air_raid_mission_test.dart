import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home mistakes retry calmly and silence requires waiting', () {
    final session = MissionSession(mode: MissionMode.home);
    session.advance();
    session.advance();
    expect(session.step.id, 'room');
    session.choose('window');
    expect(session.feedback, contains('Odsuń się'));
    session.advance();
    expect(session.step.id, 'room');
    expect(session.rejectedChoiceIds, {'window'});
    _chooseAndAdvance(session, 'interior');
    session.choose('hallway');
    expect(session.selectedChoice?.visual, MissionVisual.twoWalls);
    session.advance();
    _chooseAndAdvance(session, 'dad');
    expect(session.step.id, 'communication');
    session.choose('message');
    session.advance();
    expect(session.step.id, 'communication');
    expect(session.hasFeedback, isFalse);
    session.choose('call');
    expect(session.feedback, contains('Linia jest zajęta'));
    session.advance();
    expect(session.step.id, 'sms');
    _chooseAndAdvance(session, 'message');
    expect(session.step.id, 'message');
    session.advance();
    _chooseAndAdvance(session, 'stay');
    expect(session.step.id, 'quiet');
    session.choose('leave');
    expect(session.feedback, contains('Cisza nie oznacza'));
    session.advance();
    expect(session.step.id, 'quiet');
    _chooseAndAdvance(session, 'stay');
    expect(session.isComplete, isFalse);
    session.advance();
    expect(session.step.id, 'recall');
    session.advance();
    expect(session.isComplete, isTrue);
    session.restart();
    expect(session.step.id, 'alarm');
    expect(session.isComplete, isFalse);
  });

  test(
    'decisions have two through four choices and phone actions are guided',
    () {
      for (final mode in MissionMode.values) {
        final session = MissionSession(mode: mode);
        final visitedSteps = <String>{};
        while (!session.isComplete) {
          visitedSteps.add(session.step.id);
          if (session.step.isDecision) {
            if (session.step.id == 'communication' ||
                session.step.id == 'sms') {
              expect(session.step.choices, hasLength(1));
            } else {
              expect(session.step.choices.length, inInclusiveRange(2, 4));
            }
            final choice = session.step.choices.firstWhere(
              (choice) => choice.isCorrect,
            );
            session.choose(choice.id);
          }
          session.advance();
        }
        expect(visitedSteps, contains('quiet'));
        expect(visitedSteps, contains('recall'));
      }
    },
  );

  test('nearby outdoor shelter skips physical recovery branch', () {
    final session = MissionSession(mode: MissionMode.outdoor);
    session.advance();
    _chooseAndAdvance(session, 'shelter');
    expect(session.step.id, 'outdoor_sheltered');
    session.advance();
    expect(session.step.id, 'contacts');
  });

  test('outdoor choices stay connected to the noise and guided recovery', () {
    const destinationNames = {
      'home': 'domu',
      'school': 'szkoły',
      'park': 'otwartym parku',
      'bus_stop': 'przystanku',
    };
    for (final destination in destinationNames.keys) {
      final session = MissionSession(mode: MissionMode.outdoor);
      session.advance();
      if (destination == 'park' || destination == 'bus_stop') {
        _chooseAndAdvance(session, 'more_places');
      }
      session.choose(destination);
      expect(session.selectedChoice?.isCorrect, isFalse);
      expect(session.selectedChoice?.continuesAfterFeedback, isTrue);
      session.advance();
      expect(session.step.id, 'outdoor_noise');
      expect(session.step.narration, contains(destinationNames[destination]));
      expect(session.step.narration, contains('głośny huk'));
      expect(session.step.sound, 'noise');
      expect(session.step.isDecision, isFalse);
      session.advance();
      expect(session.step.id, 'get_down');
      expect(session.step.sound, isNull);
      session.choose('stay');
      session.advance();
      expect(session.step.id, 'get_down');
      expect(session.rejectedChoiceIds, {'stay'});
      _chooseAndAdvance(session, 'down');
      expect(session.step.id, 'protect_head');
      _chooseAndAdvance(session, 'protect_head');
      expect(session.step.id, 'outdoor_recover');
      expect(session.step.narration, contains('zaufana osoba dorosła'));
      expect(session.step.narration, contains('gdy jest to możliwe'));
      session.advance();
      expect(session.step.id, 'outdoor_sheltered');
      session.advance();
      expect(session.step.id, 'contacts');
    }
  });

  test('restarting outdoor practice clears the previous destination story', () {
    final session = MissionSession(mode: MissionMode.outdoor);
    session.advance();
    _chooseAndAdvance(session, 'home');
    expect(session.step.narration, contains('domu'));

    session.restart();
    expect(session.step.id, 'outdoor_alarm');
    expect(session.hasFeedback, isFalse);
    expect(session.isComplete, isFalse);
    session.advance();
    _chooseAndAdvance(session, 'more_places');
    _chooseAndAdvance(session, 'park');
    expect(session.step.id, 'outdoor_noise');
    expect(session.step.narration, contains('otwartym parku'));
    expect(session.step.narration, isNot(contains('domu')));
  });

  test(
    'rejected choices stay disabled and correct feedback locks the decision',
    () {
      final session = MissionSession(mode: MissionMode.home);
      session.advance();
      session.choose('unknown');
      expect(session.hasFeedback, isFalse);
      session.choose('window');
      session.choose('door');
      session.choose('window');
      expect(session.selectedChoice?.id, 'door');
      expect(session.rejectedChoiceIds, {'window', 'door'});
      session.choose('interior');
      session.choose('door');
      expect(session.selectedChoice?.id, 'interior');
      session.restart();
      expect(session.rejectedChoiceIds, isEmpty);
    },
  );
}

void _chooseAndAdvance(MissionSession session, String choiceId) {
  session.choose(choiceId);
  session.advance();
}
