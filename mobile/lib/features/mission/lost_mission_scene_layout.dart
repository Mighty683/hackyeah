import 'package:flutter/material.dart';

import 'data/lost_practice_context.dart';
import 'lost_landmarks.dart';
import 'lost_mission.dart';

/// Backdrop, pictured objects and native targets share one uncropped canvas.
const lostMissionSceneSize = Size(400, 600);
const lostMissionMinimumSceneWidth = 240.0;

enum LostSceneObjectKind {
  standingChild,
  walkingChild,
  exit,
  backgroundBuilding,
  fountain,
  informationDesk,
  adult,
  childWithStaff,
  family,
  phone,
  safe,
  photo,
}

/// Bounds are normalized against [lostMissionSceneSize], never screen pixels.
class LostSceneObject {
  const LostSceneObject({
    required this.kind,
    required this.bounds,
    this.choiceId,
    this.photoPath,
  });

  final LostSceneObjectKind kind;
  final Rect bounds;
  final String? choiceId;
  final String? photoPath;
}

class LostMissionSceneLayout {
  const LostMissionSceneLayout({
    required this.description,
    required this.objects,
    this.asset = 'assets/illustrations/lost-square-v1.png',
  });

  final String description;
  final List<LostSceneObject> objects;
  final String asset;

  Map<String, Rect> get targets => {
    for (final object in objects) ?object.choiceId: object.bounds,
  };
}

const _exitBounds = Rect.fromLTWH(.75, .27, .23, .33);
const _standingBounds = Rect.fromLTWH(.40, .63, .25, .33);
const _searchBounds = Rect.fromLTWH(.05, .63, .25, .33);
const _deskBounds = Rect.fromLTWH(.04, .29, .43, .34);
const _adultBounds = Rect.fromLTWH(.71, .45, .24, .44);
const _waitingBounds = Rect.fromLTWH(.04, .40, .56, .54);

/// Presentation metadata cannot establish a real route or safe destination.
LostMissionSceneLayout lostMissionSceneLayout(
  LostMissionStep step,
  LostPracticeContext context,
  LostMissionChoice? selectedChoice,
) => LostMissionSceneLayout(
  description: _description(step, context),
  objects: step.isDecision
      ? _decisionObjects(step)
      : _storyObjects(step, context, selectedChoice),
);

List<LostSceneObject> _decisionObjects(LostMissionStep step) => [
  if (step.id == 'no_answer')
    const LostSceneObject(
      kind: LostSceneObjectKind.childWithStaff,
      bounds: _waitingBounds,
    ),
  if (step.id == 'meeting_point')
    const LostSceneObject(
      kind: LostSceneObjectKind.standingChild,
      bounds: Rect.fromLTWH(.34, .76, .23, .22),
    ),
  if (step.id == 'helper')
    const LostSceneObject(
      kind: LostSceneObjectKind.standingChild,
      bounds: Rect.fromLTWH(.11, .65, .23, .30),
    ),
  for (var index = 0; index < step.choices.length; index++)
    if (step.choices[index].contactId == null)
      _choiceObject(step, step.choices[index], index),
];

LostSceneObject _choiceObject(
  LostMissionStep step,
  LostMissionChoice choice,
  int index,
) {
  if (choice.photoPath case final path?) {
    const slots = [
      Rect.fromLTWH(.04, .12, .43, .27),
      Rect.fromLTWH(.53, .30, .43, .27),
      Rect.fromLTWH(.04, .47, .43, .27),
    ];
    return LostSceneObject(
      kind: LostSceneObjectKind.photo,
      bounds: slots[index.clamp(0, slots.length - 1)],
      choiceId: choice.id,
      photoPath: path,
    );
  }
  final kind = switch (choice.landmarkPresetId) {
    'fountain' => LostSceneObjectKind.fountain,
    'information_desk' => LostSceneObjectKind.informationDesk,
    _ => switch (choice.icon) {
      LostActionIcon.search => LostSceneObjectKind.walkingChild,
      LostActionIcon.leave =>
        step.id == 'stranger'
            ? LostSceneObjectKind.adult
            : step.id == 'stop'
            ? LostSceneObjectKind.backgroundBuilding
            : LostSceneObjectKind.exit,
      LostActionIcon.staff => LostSceneObjectKind.informationDesk,
      LostActionIcon.unknownAdult ||
      LostActionIcon.adult => LostSceneObjectKind.adult,
      LostActionIcon.stay ||
      LostActionIcon.wait => LostSceneObjectKind.childWithStaff,
      LostActionIcon.call => LostSceneObjectKind.phone,
      LostActionIcon.safe => LostSceneObjectKind.safe,
      _ => LostSceneObjectKind.standingChild,
    },
  };
  return LostSceneObject(
    kind: kind,
    bounds: _choiceBounds(step, kind, index),
    choiceId: choice.id,
  );
}

Rect _choiceBounds(LostMissionStep step, LostSceneObjectKind kind, int index) {
  if (step.id == 'meeting_point') {
    final hasPhotos = step.choices.any((choice) => choice.photoPath != null);
    if (hasPhotos) {
      const photoSlots = [
        Rect.fromLTWH(.04, .12, .43, .27),
        Rect.fromLTWH(.53, .30, .43, .27),
        Rect.fromLTWH(.04, .47, .43, .27),
      ];
      return kind == LostSceneObjectKind.exit
          ? const Rect.fromLTWH(.73, .67, .24, .30)
          : photoSlots[index.clamp(0, photoSlots.length - 1)];
    }
    return switch (kind) {
      LostSceneObjectKind.fountain => const Rect.fromLTWH(.04, .46, .43, .30),
      LostSceneObjectKind.informationDesk => const Rect.fromLTWH(
        .53,
        .60,
        .43,
        .32,
      ),
      _ => const Rect.fromLTWH(.75, .25, .23, .30),
    };
  }
  return switch (kind) {
    LostSceneObjectKind.backgroundBuilding => const Rect.fromLTWH(
      .20,
      .085,
      .43,
      .24,
    ),
    LostSceneObjectKind.exit => _exitBounds,
    LostSceneObjectKind.adult => _adultBounds,
    LostSceneObjectKind.informationDesk => _deskBounds,
    LostSceneObjectKind.childWithStaff => _waitingBounds,
    LostSceneObjectKind.walkingChild => switch (step.id) {
      'point_unavailable' => const Rect.fromLTWH(.70, .65, .25, .30),
      'helper' => const Rect.fromLTWH(.42, .65, .24, .31),
      _ => _searchBounds,
    },
    LostSceneObjectKind.standingChild => _standingBounds,
    _ => Rect.fromLTWH(.06 + .30 * index, .58, .25, .33),
  };
}

List<LostSceneObject> _storyObjects(
  LostMissionStep step,
  LostPracticeContext context,
  LostMissionChoice? selectedChoice,
) {
  final photo = context.photoMeetingPoint;
  final landmarkKind = context.meetingPoint.presetId == 'information_desk'
      ? LostSceneObjectKind.informationDesk
      : LostSceneObjectKind.fountain;
  final landmark = LostSceneObject(
    kind: photo == null ? landmarkKind : LostSceneObjectKind.photo,
    bounds: const Rect.fromLTWH(.12, .25, .55, .36),
    photoPath: photo?.photoPath,
  );
  final arriving = step.id == 'arrive' || selectedChoice?.isCorrect == true;
  return switch (step.visual) {
    LostMissionVisual.look || LostMissionVisual.meetingPoint => [
      landmark,
      LostSceneObject(
        kind: arriving
            ? LostSceneObjectKind.walkingChild
            : LostSceneObjectKind.standingChild,
        bounds: arriving
            ? const Rect.fromLTWH(.49, .57, .25, .33)
            : _standingBounds,
      ),
    ],
    LostMissionVisual.reunion => const [
      LostSceneObject(
        kind: LostSceneObjectKind.family,
        bounds: Rect.fromLTWH(.22, .43, .58, .52),
      ),
    ],
    LostMissionVisual.confirmation => const [
      LostSceneObject(
        kind: LostSceneObjectKind.family,
        bounds: Rect.fromLTWH(.22, .43, .58, .52),
      ),
      LostSceneObject(
        kind: LostSceneObjectKind.safe,
        bounds: Rect.fromLTWH(.39, .22, .22, .16),
      ),
    ],
    LostMissionVisual.calling || LostMissionVisual.contacts => const [
      LostSceneObject(
        kind: LostSceneObjectKind.childWithStaff,
        bounds: _waitingBounds,
      ),
      LostSceneObject(
        kind: LostSceneObjectKind.phone,
        bounds: Rect.fromLTWH(.71, .53, .22, .25),
      ),
    ],
    _ => const [
      LostSceneObject(
        kind: LostSceneObjectKind.informationDesk,
        bounds: _deskBounds,
      ),
      LostSceneObject(
        kind: LostSceneObjectKind.standingChild,
        bounds: _standingBounds,
      ),
    ],
  };
}

String _description(
  LostMissionStep step,
  LostPracticeContext context,
) => switch (step.visual) {
  LostMissionVisual.look || LostMissionVisual.meetingPoint =>
    'Miejsce spotkania do ćwiczeń: ${context.meetingPointLabel}. '
        '${context.photoMeetingPoint == null ? resolveLostLandmark(context.meetingPoint.presetId).description : 'Zapisane zdjęcie miejsca spotkania.'} '
        'To fikcyjna historia, nie wskazówka nawigacji.',
  LostMissionVisual.helper || LostMissionVisual.waiting =>
    'Dziecko jest w miejscu publicznym przy punkcie informacji. '
        'Pracownik może pomóc skontaktować się z rodziną tutaj.',
  LostMissionVisual.stranger =>
    'Osoba proponuje odejście. Punkt informacji pozostaje w pobliżu.',
  LostMissionVisual.contacts || LostMissionVisual.calling =>
    'Połączenie do rodziny na niby. Bez prawdziwego połączenia.',
  LostMissionVisual.reunion => 'W tej historii dziecko i rodzic znów są razem.',
  LostMissionVisual.confirmation =>
    'Potwierdzenie bezpieczeństwa na niby. Żadna wiadomość nie jest wysyłana.',
  _ => 'Dziecko nie widzi rodzica na fikcyjnym placu publicznym.',
};
