import '../../parent/data/family_plan.dart';
import '../lost_landmarks.dart';

enum LostContactAvatar { mother, father, grandparent, adult }

/// Photo recognition data only. Geographic pins stay with the map screen.
class LostPracticePlace {
  const LostPracticePlace({
    required this.id,
    required this.label,
    required this.photoPath,
    this.isDemo = false,
  });

  final String id;
  final String label;
  final String photoPath;
  final bool isDemo;
}

class LostPracticeContact {
  const LostPracticeContact({
    required this.id,
    required this.label,
    this.avatar = LostContactAvatar.adult,
    this.isFictional = false,
  });

  final String id;
  final String label;
  final LostContactAvatar avatar;
  final bool isFictional;
}

/// Display-only snapshot. Real phone numbers and locations stay outside play.
class LostPracticeContext {
  const LostPracticeContext({
    required this.childName,
    required this.gender,
    required this.meetingPoint,
    required this.contacts,
    required this.fictionalMeetingPoint,
    this.photoPlaces = const [],
  });

  factory LostPracticeContext.fromFamilyPlan(
    FamilyPlan plan, {
    ChildProfile fallbackChild = const ChildProfile(),
    List<LostPracticePlace> photoPlaces = const [],
  }) {
    final configuredPoint = plan.practiceMeetingPoint;
    final linkedPlace = photoPlaces
        .where((place) => place.id == configuredPoint?.landmarkId)
        .firstOrNull;
    final preset = resolveLostLandmark(configuredPoint?.presetId ?? 'fountain');
    final unknownPreset =
        configuredPoint != null && configuredPoint.presetId != preset.id;
    final savedLabel = configuredPoint?.label.trim() ?? '';
    final childName = plan.child.fullName.trim();
    final contacts = <LostPracticeContact>[];
    for (var index = 0; index < plan.contacts.length; index++) {
      final contact = plan.contacts[index];
      final name = contact.name.trim();
      final relationship = contact.relationship.trim();
      if (name.isEmpty && relationship.isEmpty) continue;
      contacts.add(
        LostPracticeContact(
          id: 'contact-$index',
          label: name.isEmpty ? relationship : name,
          avatar: _contactAvatar('$relationship $name'),
        ),
      );
      if (contacts.length == FamilyPlan.maxContacts) break;
    }
    if (contacts.isEmpty) {
      contacts.add(
        const LostPracticeContact(
          id: 'fictional-parent',
          label: 'Pretend parent',
          avatar: LostContactAvatar.mother,
          isFictional: true,
        ),
      );
    }
    if (contacts.length == 1) {
      contacts.add(
        const LostPracticeContact(
          id: 'fictional-grandparent',
          label: 'Pretend grandparent',
          avatar: LostContactAvatar.grandparent,
          isFictional: true,
        ),
      );
    }
    return LostPracticeContext(
      childName: childName.isEmpty ? fallbackChild.fullName.trim() : childName,
      gender: plan.child.gender ?? fallbackChild.gender ?? ChildGender.girl,
      meetingPoint: PracticeMeetingPoint(
        presetId: preset.id,
        landmarkId: configuredPoint?.landmarkId,
        label:
            linkedPlace?.label ??
            (unknownPreset
                ? 'Pretend fountain'
                : savedLabel.isEmpty
                ? preset.label
                : savedLabel),
      ),
      contacts: List.unmodifiable(contacts),
      fictionalMeetingPoint:
          configuredPoint?.landmarkId == null || linkedPlace?.isDemo == true,
      photoPlaces: List.unmodifiable(photoPlaces),
    );
  }

  factory LostPracticeContext.fictional({
    ChildProfile child = const ChildProfile(),
  }) => LostPracticeContext.fromFamilyPlan(FamilyPlan(child: child));

  final String childName;
  final ChildGender gender;
  final PracticeMeetingPoint meetingPoint;
  final List<LostPracticeContact> contacts;
  final bool fictionalMeetingPoint;
  final List<LostPracticePlace> photoPlaces;

  LostPracticePlace? get photoMeetingPoint => photoPlaces
      .where((place) => place.id == meetingPoint.landmarkId)
      .firstOrNull;

  bool get meetingPointUnavailable =>
      meetingPoint.landmarkId != null && photoMeetingPoint == null;

  String get meetingPointLabel => meetingPoint.label;

  bool get usesFictionalDetails =>
      fictionalMeetingPoint || contacts.any((contact) => contact.isFictional);
}

LostContactAvatar _contactAvatar(String description) {
  final words = description.toLowerCase().split(RegExp(r'[^a-z]+'));
  if (words.any(
    const {
      'grandparent',
      'grandmother',
      'grandfather',
      'grandma',
      'grandpa',
    }.contains,
  )) {
    return LostContactAvatar.grandparent;
  }
  if (words.any(const {'mother', 'mom', 'mum', 'mummy', 'mommy'}.contains)) {
    return LostContactAvatar.mother;
  }
  if (words.any(const {'father', 'dad', 'daddy'}.contains)) {
    return LostContactAvatar.father;
  }
  return LostContactAvatar.adult;
}
