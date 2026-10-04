import 'package:do_bazy/features/mission/data/lost_practice_context.dart';
import 'package:do_bazy/features/mission/lost_mission.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both variants reach reunion, explicit confirmation and recall', () {
    for (final variant in LostPracticeVariant.values) {
      final session = _session(variant: variant);
      final visited = <String>[];
      for (var steps = 0; steps < 30 && !session.isComplete; steps++) {
        visited.add(session.step.id);
        final confirming = session.step.id == 'confirm_safe';
        if (!visited.contains('confirmation')) {
          expect(session.safetyConfirmed, isFalse);
        }
        if (confirming) {
          expect(visited, contains('reunion'));
          expect(session.step.actionLabel, "JESTEM W BEZPIECZNYM MIEJSCU");
          expect(session.step.isDecision, isFalse);
        }
        if (session.step.isDecision) {
          _chooseCorrect(session);
        } else {
          expect(session.step.actionLabel, isNotEmpty);
          expect(session.step.actionLabel, isNot('Continue'));
        }
        session.advance();
        if (confirming) {
          expect(session.safetyConfirmed, isTrue);
          expect(session.step.id, 'confirmation');
          expect(
            session.step.narration,
            contains('Nie wysłano żadnej wiadomości'),
          );
        }
      }
      expect(session.isComplete, isTrue);
      expect(visited, [
        'stop',
        'look',
        if (variant == LostPracticeVariant.meetingPointNearby) ...[
          'meeting_point',
          'arrive',
        ] else
          'point_unavailable',
        'helper',
        'stranger',
        'contact',
        'no_answer',
        'reply',
        'wait',
        'reunion',
        'confirm_safe',
        'confirmation',
        'recall',
      ]);
      expect(session.step.narration, contains('widzisz je blisko'));
      expect(session.safetyConfirmed, isTrue);
    }
  });

  test('unsafe decisions lock feedback and cannot advance until retried', () {
    for (final variant in LostPracticeVariant.values) {
      final session = _session(variant: variant);
      for (var steps = 0; steps < 30 && !session.isComplete; steps++) {
        final step = session.step;
        if (!step.isDecision) {
          session.advance();
          continue;
        }
        expect(step.choices.length, inInclusiveRange(2, 4));
        session.advance();
        expect(session.step.id, step.id);
        session.choose('not-a-choice');
        expect(session.hasFeedback, isFalse);
        final correct = step.choices.firstWhere((choice) => choice.isCorrect);
        for (final unsafe in step.choices.where(
          (choice) => !choice.isCorrect,
        )) {
          session.choose(unsafe.id);
          expect(session.feedback, isNotEmpty);
          session.choose(correct.id);
          expect(session.selectedChoice?.id, unsafe.id);
          session.advance();
          session.advance();
          expect(session.step.id, step.id);
          expect(session.safetyConfirmed, isFalse);
          session.retry();
          expect(session.hasFeedback, isFalse);
          expect(session.feedback, isNull);
        }
        session.choose(correct.id);
        session.retry();
        expect(session.selectedChoice?.id, correct.id);
        session.advance();
      }
      expect(session.isComplete, isTrue);
    }
  });

  test(
    'unanswered call offers a different trusted person for every first choice',
    () {
      for (final count in [2, 3]) {
        final context = _context(contactCount: count);
        for (final first in context.contacts) {
          final session = LostMissionSession(
            variant: LostPracticeVariant.meetingPointNearby,
            context: context,
          );
          _progressTo(session, 'contact');
          session.choose(first.id);
          expect(session.selectedChoice?.contactId, first.id);
          expect(session.feedback, contains('na niby'));
          session.advance();
          expect(session.firstContactId, first.id);
          expect(session.step.id, 'no_answer');
          expect(session.step.choices.length, inInclusiveRange(2, 4));
          final alternates = session.step.choices.where(
            (choice) => choice.isCorrect,
          );
          expect(alternates.length, count - 1);
          expect(
            alternates.every((choice) => choice.contactId != first.id),
            isTrue,
          );
          session.choose(first.id);
          expect(session.hasFeedback, isFalse);
          session.advance();
          expect(session.step.id, 'no_answer');
          session.choose('leave');
          session.advance();
          expect(session.step.id, 'no_answer');
          session.retry();
          expect(session.firstContactId, first.id);
          session.choose(alternates.first.id);
          expect(session.feedback, contains('na niby'));
          session.advance();
          expect(session.step.id, 'reply');
        }
      }
    },
  );

  test('only the explicit post-reunion action confirms safety', () {
    final session = _session();
    session.choose('confirm_safe');
    session.choose("JESTEM W BEZPIECZNYM MIEJSCU");
    session.advance();
    expect(session.step.id, 'stop');
    expect(session.safetyConfirmed, isFalse);
    _progressTo(session, 'reunion');
    expect(session.safetyConfirmed, isFalse);
    session.advance();
    expect(session.step.id, 'confirm_safe');
    expect(session.safetyConfirmed, isFalse);
    session.choose('safe');
    expect(session.safetyConfirmed, isFalse);
    session.advance();
    expect(session.safetyConfirmed, isTrue);
    expect(session.isComplete, isFalse);
    session.advance();
    expect(session.step.id, 'recall');
    expect(session.isComplete, isFalse);
    session.advance();
    expect(session.isComplete, isTrue);
    session.choose('leave');
    session.advance();
    session.retry();
    expect(session.step.id, 'recall');
    expect(session.isComplete, isTrue);
    expect(session.selectedChoice, isNull);
  });

  test('restart clears pending feedback, contact attempt and confirmation', () {
    final session = _session(
      variant: LostPracticeVariant.meetingPointUnavailable,
    );
    _progressTo(session, 'no_answer');
    session.choose('leave');
    expect(session.firstContactId, isNotNull);
    expect(session.hasFeedback, isTrue);
    session.restart();
    _expectFresh(session);
    _progressTo(session, 'recall');
    session.advance();
    expect(session.safetyConfirmed, isTrue);
    expect(session.isComplete, isTrue);
    session.restart();
    _expectFresh(session);
    _chooseCorrect(session);
    session.advance();
    session.advance();
    expect(session.step.id, 'point_unavailable');
  });

  test(
    'configured and unknown landmark presets keep recognition consistent',
    () {
      for (final preset in [
        'fountain',
        'information_desk',
        'old-unknown-preset',
      ]) {
        final context = LostPracticeContext.fromFamilyPlan(
          FamilyPlan(
            practiceMeetingPoint: PracticeMeetingPoint(
              presetId: preset,
              label: 'Our meeting place',
            ),
          ),
        );
        final session = LostMissionSession(
          variant: LostPracticeVariant.meetingPointNearby,
          context: context,
        );
        _progressTo(session, 'look');
        expect(session.step.narration, contains(context.meetingPointLabel));
        session.advance();
        final correct = session.step.choices.singleWhere(
          (choice) => choice.isCorrect,
        );
        expect(correct.label, context.meetingPointLabel);
        expect(
          correct.landmarkPresetId,
          preset == 'information_desk' ? 'information_desk' : 'fountain',
        );
        session.choose(correct.id);
        session.advance();
        expect(session.step.id, 'arrive');
        expect(session.step.narration, contains(context.meetingPointLabel));
      }
    },
  );
  test('map help returns to staying nearby; selecting a pin does not confirm safety', () {
    final context = LostPracticeContext.fromFamilyPlan(
      const FamilyPlan(
        practiceMeetingPoint: PracticeMeetingPoint(landmarkId: '1_1'),
      ),
      photoPlaces: [
        LostPracticePlace(
          id: '1_1',
          label: 'Library entrance',
          photoPath: '/practice/1_1.photo',
        ),
        LostPracticePlace(
          id: '2_2',
          label: 'Library entrance',
          photoPath: '/practice/2_2.photo',
        ),
      ],
    );
    final session = LostMissionSession(
      variant: LostPracticeVariant.meetingPointNearby,
      context: context,
    );
    session.choose('stop');
    session.advance();
    session.advance();
    session.choose('2_2');
    session.advance();
    expect(session.step.id, 'meeting_point');
    session.retry();
    session.choose('1_1');
    session.advance();
    expect(session.step.id, 'map_meeting_point');
    session.advance();
    expect(session.step.id, 'map_meeting_point');
    session.useMapHelp();
    expect(session.step.id, 'point_unavailable');
    session.choose('stay');
    session.advance();
    expect(session.step.id, 'helper');
    expect(session.safetyConfirmed, isFalse);
    session.restart();
    session.choose('stop');
    session.advance();
    session.advance();
    session.choose('1_1');
    session.advance();
    session.choose('1_1');
    session.advance();
    expect(session.step.id, 'arrive');
    expect(session.safetyConfirmed, isFalse);
  });
}

LostMissionSession _session({
  LostPracticeVariant variant = LostPracticeVariant.meetingPointNearby,
}) => LostMissionSession(variant: variant, context: _context());

LostPracticeContext _context({int contactCount = 3}) => LostPracticeContext(
  childName: 'Alex',
  gender: ChildGender.girl,
  meetingPoint: const PracticeMeetingPoint(
    presetId: 'fountain',
    label: 'Fontanna',
  ),
  fictionalMeetingPoint: true,
  contacts: List.unmodifiable([
    const LostPracticeContact(
      id: 'mom',
      label: 'Mama',
      avatar: LostContactAvatar.mother,
      isFictional: true,
    ),
    const LostPracticeContact(
      id: 'dad',
      label: 'Tata',
      avatar: LostContactAvatar.father,
      isFictional: true,
    ),
    if (contactCount == 3)
      const LostPracticeContact(
        id: 'grandparent',
        label: 'Babcia lub dziadek',
        avatar: LostContactAvatar.grandparent,
        isFictional: true,
      ),
  ]),
);

void _chooseCorrect(LostMissionSession session) => session.choose(
  session.step.choices.firstWhere((choice) => choice.isCorrect).id,
);

void _progressTo(LostMissionSession session, String target) {
  for (var steps = 0; steps < 30 && session.step.id != target; steps++) {
    expect(session.isComplete, isFalse, reason: 'Did not reach $target');
    if (session.step.isDecision) _chooseCorrect(session);
    session.advance();
  }
  expect(session.step.id, target);
}

void _expectFresh(LostMissionSession session) {
  expect(session.step.id, 'stop');
  expect(session.firstContactId, isNull);
  expect(session.safetyConfirmed, isFalse);
  expect(session.isComplete, isFalse);
  expect(session.selectedChoice, isNull);
  expect(session.feedback, isNull);
}
