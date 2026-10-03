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
    expect(session.rejectedChoiceIds, {'window'});
    _chooseAndAdvance(session, 'interior');
    session.choose('hallway');
    expect(session.selectedChoice?.visual, MissionVisual.twoWalls);
    session.advance();
    _chooseAndAdvance(session, 'dad');
    session.choose('call');
    session.advance();
    expect(session.step.id, 'communication');
    _chooseAndAdvance(session, 'message');
    expect(session.step.id, 'message');
    session.advance();
    _chooseAndAdvance(session, 'stay');
    expect(session.step.id, 'quiet');
    session.choose('leave');
    expect(session.feedback, contains('Quiet does not mean'));
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

  test(
    'outdoor mistakes reject the path and allow another choice immediately',
    () {
      for (final destination in ['home', 'school', 'park', 'bus_stop']) {
        final session = MissionSession(mode: MissionMode.outdoor);
        session.advance();
        if (destination == 'park' || destination == 'bus_stop') {
          _chooseAndAdvance(session, 'more_places');
        }
        session.choose(destination);
        expect(session.selectedChoice?.isCorrect, isFalse);
        expect(session.feedback, contains('wrong path'));
        expect(session.rejectedChoiceIds, {destination});
        final stepId = session.step.id;
        session.advance();
        expect(session.step.id, stepId);
        _chooseAndAdvance(session, 'shelter');
        expect(session.step.id, 'outdoor_sheltered');
        expect(session.rejectedChoiceIds, isEmpty);
        session.advance();
        expect(session.step.id, 'contacts');
      }
    },
  );

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
