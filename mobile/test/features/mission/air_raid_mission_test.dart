import 'package:do_bazy/features/mission/air_raid_mission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home mistakes retry calmly and silence requires waiting', () {
    final session = MissionSession(mode: MissionMode.home);
    session.advance();
    session.advance();
    expect(session.step.id, 'room');
    session.choose('window');
    expect(session.feedback, contains('Move away'));
    session.advance();
    expect(session.step.id, 'room');
    session.retry();
    expect(session.hasFeedback, isFalse);
    _chooseAndAdvance(session, 'interior');
    session.choose('hallway');
    expect(session.selectedChoice?.visual, MissionVisual.twoWalls);
    session.advance();
    _chooseAndAdvance(session, 'dad');
    session.choose('call');
    session.advance();
    expect(session.step.id, 'communication');
    session.retry();
    _chooseAndAdvance(session, 'message');
    expect(session.step.id, 'message');
    session.advance();
    _chooseAndAdvance(session, 'stay');
    expect(session.step.id, 'quiet');
    session.choose('leave');
    expect(session.feedback, contains('Quiet does not mean'));
    session.advance();
    expect(session.step.id, 'quiet');
    session.retry();
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
    'home and outdoor practice keep decisions to two through four choices',
    () {
      for (final mode in MissionMode.values) {
        final session = MissionSession(mode: mode);
        final visitedSteps = <String>{};
        while (!session.isComplete) {
          visitedSteps.add(session.step.id);
          if (session.step.isDecision) {
            expect(session.step.choices.length, inInclusiveRange(2, 4));
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
      'home': 'home',
      'school': 'school',
      'park': 'open park',
      'bus_stop': 'bus stop',
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
      expect(session.step.narration, contains('loud noise'));
      expect(session.step.sound, 'noise');
      expect(session.step.isDecision, isFalse);
      session.advance();
      expect(session.step.id, 'get_down');
      expect(session.step.sound, isNull);
      session.choose('stay');
      session.advance();
      expect(session.step.id, 'get_down');
      session.retry();
      _chooseAndAdvance(session, 'down');
      expect(session.step.id, 'protect_head');
      _chooseAndAdvance(session, 'protect_head');
      expect(session.step.id, 'outdoor_recover');
      expect(session.step.narration, contains('trusted adult'));
      expect(session.step.narration, contains('when it is possible'));
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
    expect(session.step.narration, contains('home'));

    session.restart();
    expect(session.step.id, 'outdoor_alarm');
    expect(session.hasFeedback, isFalse);
    expect(session.isComplete, isFalse);
    session.advance();
    _chooseAndAdvance(session, 'more_places');
    _chooseAndAdvance(session, 'park');
    expect(session.step.id, 'outdoor_noise');
    expect(session.step.narration, contains('open park'));
    expect(session.step.narration, isNot(contains('home')));
  });

  test('choice cannot be changed until feedback is acknowledged', () {
    final session = MissionSession(mode: MissionMode.home);
    session.advance();
    session.choose('unknown');
    expect(session.hasFeedback, isFalse);
    session.choose('window');
    session.choose('interior');
    expect(session.selectedChoice?.id, 'window');
  });
}

void _chooseAndAdvance(MissionSession session, String choiceId) {
  session.choose(choiceId);
  session.advance();
}
