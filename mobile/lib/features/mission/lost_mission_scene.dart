import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/child_character.dart';
import '../landmarks/widgets/landmark_photo.dart';
import 'data/lost_practice_context.dart';
import 'lost_landmarks.dart';
import 'lost_mission.dart';
import 'lost_mission_choice_card.dart';
import 'lost_mission_scene_layout.dart';
import 'practice_contact_picker.dart';

/// Fictional square with independently labelled, clickable scene objects.
class LostMissionScene extends StatelessWidget {
  const LostMissionScene({
    super.key,
    required this.step,
    required this.practiceContext,
    this.selectedChoice,
    this.onChoice,
  });

  final LostMissionStep step;
  final LostPracticeContext practiceContext;
  final LostMissionChoice? selectedChoice;
  final ValueChanged<String>? onChoice;

  @override
  Widget build(BuildContext context) {
    if (step.visual == LostMissionVisual.contacts) {
      return Column(
        children: [
          PracticeContactPicker(
            contacts: [
              for (final choice in step.choices)
                if (choice.contactId != null)
                  PracticeContactChoice(
                    id: choice.id,
                    key: ValueKey('lost-choice-${choice.id}'),
                    label: practiceContext.contacts
                        .firstWhere((contact) => contact.id == choice.contactId)
                        .label,
                    avatar: lostActionIcon(choice.icon),
                  ),
            ],
            selectedId: selectedChoice?.id,
            onChoose: onChoice,
          ),
          if (selectedChoice == null)
            for (final choice in step.choices)
              if (choice.contactId == null)
                LostMissionChoiceCard(
                  key: ValueKey('lost-choice-${choice.id}'),
                  choice: choice,
                  onPressed: onChoice == null
                      ? null
                      : () => onChoice!(choice.id),
                ),
        ],
      );
    }
    final layout = lostMissionSceneLayout(
      step,
      practiceContext,
      selectedChoice,
    );
    if (step.isDecision && selectedChoice == null) {
      return _decisionScene(context, layout);
    }
    return Semantics(
      image: true,
      label: layout.description,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: BaseboundColors.sky,
            child: layout.motif == LostSceneMotif.recall
                ? const _RecallPictures()
                : _story(context, layout),
          ),
        ),
      ),
    );
  }

  Widget _decisionScene(
    BuildContext context,
    LostMissionSceneLayout layout,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      // Let labels wrap and the scene grow instead of covering other targets.
      final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final columns = (constraints.maxWidth / (132 * textScale)).floor().clamp(
        1,
        step.choices.length,
      );
      final targetWidth =
          (constraints.maxWidth - 24 - 16 * (columns - 1)) / columns;
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                image: true,
                label: layout.description,
                child: const ExcludeSemantics(
                  child: CustomPaint(painter: _SquareBackdropPainter()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 24,
                children: [
                  for (final choice in step.choices)
                    SizedBox(
                      width: targetWidth,
                      child: LostMissionChoiceCard(
                        key: ValueKey('lost-choice-${choice.id}'),
                        choice: choice,
                        childGender: practiceContext.gender,
                        onPressed: onChoice == null
                            ? null
                            : () => onChoice!(choice.id),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _story(
    BuildContext context,
    LostMissionSceneLayout layout,
  ) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _SquareBackdropPainter()),
        Positioned(
          top: 8,
          right: constraints.maxWidth * .10,
          width: constraints.maxWidth * .43,
          height: constraints.maxHeight * .67,
          child: Center(child: _motif(layout.motif)),
        ),
        AnimatedPositioned(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          left: constraints.maxWidth * (layout.childAtMeetingPoint ? .43 : .12),
          bottom: 5,
          width: constraints.maxWidth * .25,
          height: constraints.maxHeight * .75,
          child: ChildCharacter(
            pose: layout.childPose,
            gender: practiceContext.gender,
          ),
        ),
      ],
    ),
  );

  Widget _motif(LostSceneMotif motif) => switch (motif) {
    LostSceneMotif.landmark =>
      practiceContext.photoMeetingPoint != null
          ? LandmarkPhoto(
              fit: BoxFit.contain,
              path: practiceContext.photoMeetingPoint!.photoPath,
              label: practiceContext.meetingPointLabel,
              height: 126,
            )
          : LostLandmarkIllustration(
              presetId: practiceContext.meetingPoint.presetId,
              size: 126,
            ),
    LostSceneMotif.helper => const LostLandmarkIllustration(
      presetId: 'information_desk',
      size: 126,
    ),
    LostSceneMotif.square => const BaseboundIcon(
      BaseboundIconName.lost,
      size: 82,
    ),
    LostSceneMotif.stranger => const BaseboundIcon(
      BaseboundIconName.adult,
      size: 88,
    ),
    LostSceneMotif.phone => const BaseboundIcon(
      BaseboundIconName.phone,
      size: 90,
    ),
    LostSceneMotif.family => const BaseboundIcon(
      BaseboundIconName.family,
      size: 110,
    ),
    LostSceneMotif.safe => const BaseboundIcon(
      BaseboundIconName.check,
      size: 100,
      color: BaseboundColors.green,
    ),
    LostSceneMotif.recall => const SizedBox.shrink(),
  };
}

class _RecallPictures extends StatelessWidget {
  const _RecallPictures();

  static const _steps = [
    (BaseboundIconName.stay, 'Zatrzymaj się'),
    (BaseboundIconName.lost, 'Spójrz'),
    (BaseboundIconName.pin, 'Jeśli blisko'),
    (BaseboundIconName.help, 'Poproś o pomoc'),
    (BaseboundIconName.family, 'Rodzina'),
    (BaseboundIconName.wait, 'Czekaj'),
    (BaseboundIconName.check, "Jestem w bezpiecznym miejscu"),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 12,
      children: [for (final (icon, label) in _steps) _picture(icon, label)],
    ),
  );

  Widget _picture(BaseboundIconName icon, String label) => SizedBox(
    width: 86,
    child: Column(
      children: [
        BaseboundIcon(icon, size: 42),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ],
    ),
  );
}

class _SquareBackdropPainter extends CustomPainter {
  const _SquareBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = BaseboundColors.sky);
    final ground = Rect.fromLTWH(0, size.height * .61, size.width, size.height);
    canvas.drawRect(ground, Paint()..color = BaseboundColors.cream);
    final buildingPaint = Paint()..color = BaseboundColors.peach;
    for (final x in [.04, .36, .76]) {
      final building = Rect.fromLTWH(
        size.width * x,
        size.height * .20,
        size.width * .19,
        size.height * .40,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(building, const Radius.circular(12)),
        buildingPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            building.left + building.width * .25,
            building.top + building.height * .20,
            building.width * .50,
            building.height * .25,
          ),
          const Radius.circular(5),
        ),
        Paint()..color = Colors.white.withValues(alpha: .65),
      );
    }
    canvas.drawOval(
      Rect.fromLTWH(size.width * .10, size.height * .89, size.width * .73, 10),
      Paint()..color = BaseboundColors.ink.withValues(alpha: .05),
    );
  }

  @override
  bool shouldRepaint(_SquareBackdropPainter oldDelegate) => false;
}
