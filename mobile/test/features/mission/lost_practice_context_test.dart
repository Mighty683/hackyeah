import 'package:do_bazy/features/mission/data/lost_practice_context.dart';
import 'package:do_bazy/features/parent/data/family_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('old plans load and new practice landmarks round-trip and clear', () {
    final oldRecord = const FamilyPlan(
      contacts: [TrustedContact(name: 'Demo adult')],
      safePoints: [SafePoint(name: 'Demo pin', latitude: 50, longitude: 20)],
    ).toJson();
    expect(oldRecord.containsKey('practiceMeetingPoint'), isFalse);
    final oldPlan = FamilyPlan.fromJson(oldRecord);
    expect(oldPlan.practiceMeetingPoint, isNull);
    final updated = oldPlan.copyWith(
      practiceMeetingPoint: const PracticeMeetingPoint(
        presetId: 'information_desk',
        label: 'Demo help desk',
      ),
    );
    final restored = FamilyPlan.fromJson(updated.toJson());
    expect(restored.toJson()['version'], 1);
    expect(restored.practiceMeetingPoint!.presetId, 'information_desk');
    expect(restored.practiceMeetingPoint!.label, 'Demo help desk');
    final edited = restored.copyWith(
      child: const ChildProfile(fullName: 'Demo'),
    );
    expect(edited.practiceMeetingPoint!.label, 'Demo help desk');
    final cleared = edited.copyWith(clearPracticeMeetingPoint: true);
    expect(FamilyPlan.fromJson(cleared.toJson()).practiceMeetingPoint, isNull);
    expect(cleared.contacts.single.name, 'Demo adult');
    expect(cleared.safePoints.single.name, 'Demo pin');
  });

  test(
    'configured display context retains labels and derives contact avatars',
    () {
      final context = LostPracticeContext.fromFamilyPlan(
        const FamilyPlan(
          child: ChildProfile(
            fullName: ' Demo child ',
            gender: ChildGender.boy,
          ),
          practiceMeetingPoint: PracticeMeetingPoint(
            presetId: 'information_desk',
            label: ' Our help desk ',
          ),
          contacts: [
            TrustedContact(name: 'Emma', relationship: 'Mother'),
            TrustedContact(name: 'Sam', relationship: 'Grandfather'),
            TrustedContact(name: 'Ali', relationship: 'Family friend'),
          ],
        ),
      );
      expect(context.childName, 'Demo child');
      expect(context.gender, ChildGender.boy);
      expect(context.meetingPointLabel, 'Our help desk');
      expect(context.meetingPoint.presetId, 'information_desk');
      expect(context.fictionalMeetingPoint, isTrue);
      expect(context.contacts.map((contact) => contact.label), [
        'Emma',
        'Sam',
        'Ali',
      ]);
      expect(context.contacts.map((contact) => contact.avatar), [
        LostContactAvatar.mother,
        LostContactAvatar.grandparent,
        LostContactAvatar.adult,
      ]);
      expect(
        context.contacts.map((contact) => contact.id).toSet(),
        hasLength(3),
      );
      expect(() => context.contacts.clear(), throwsUnsupportedError);
    },
  );

  test('one usable contact gets a clearly fictional second practice adult', () {
    final context = LostPracticeContext.fromFamilyPlan(
      const FamilyPlan(
        contacts: [
          TrustedContact(phone: '123456789'),
          TrustedContact(relationship: ' Dad '),
          TrustedContact(name: '   '),
        ],
      ),
      fallbackChild: const ChildProfile(
        fullName: 'Fallback',
        gender: ChildGender.boy,
      ),
    );
    expect(context.childName, 'Fallback');
    expect(context.gender, ChildGender.boy);
    expect(context.contacts, hasLength(2));
    expect(context.contacts.first.label, 'Dad');
    expect(context.contacts.first.avatar, LostContactAvatar.father);
    expect(context.contacts.first.isFictional, isFalse);
    expect(context.contacts.last.isFictional, isTrue);
    expect(context.contacts.last.label, startsWith('Pretend'));
    expect(context.contacts.first.id, isNot(context.contacts.last.id));
    expect(context.fictionalMeetingPoint, isTrue);
    expect(context.usesFictionalDetails, isTrue);
  });

  test(
    'fictional defaults and unknown presets use explicit fountain fallback',
    () {
      final fictional = LostPracticeContext.fictional(
        child: const ChildProfile(fullName: 'Demo'),
      );
      expect(fictional.childName, 'Demo');
      expect(fictional.contacts, hasLength(2));
      expect(
        fictional.contacts.every((contact) => contact.isFictional),
        isTrue,
      );
      expect(fictional.meetingPoint.presetId, 'fountain');
      expect(fictional.fictionalMeetingPoint, isTrue);
      final unknown = LostPracticeContext.fromFamilyPlan(
        const FamilyPlan(
          practiceMeetingPoint: PracticeMeetingPoint(
            presetId: 'removed-preset',
            label: 'A different real place',
          ),
        ),
      );
      expect(unknown.meetingPoint.presetId, 'fountain');
      expect(unknown.meetingPointLabel, 'Pretend fountain');
      expect(unknown.fictionalMeetingPoint, isTrue);
    },
  );
}
