import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import 'data/lost_practice_context.dart';
import 'lost_mission.dart';
import 'lost_mission_choice_card.dart';
import 'lost_mission_scene_layout.dart';
import 'lost_scene_objects.dart';
import 'practice_contact_picker.dart';
import 'scene_object_target.dart';

/// A fictional pictured situation with accessible controls on its objects.
class LostMissionScene extends StatelessWidget {
  const LostMissionScene({
    super.key,
    required this.step,
    required this.practiceContext,
    this.selectedChoice,
    this.rejectedChoiceIds = const {},
    this.onChoice,
  });

  final LostMissionStep step;
  final LostPracticeContext practiceContext;
  final LostMissionChoice? selectedChoice;
  final Set<String> rejectedChoiceIds;
  final ValueChanged<String>? onChoice;

  @override
  Widget build(BuildContext context) {
    final layout = lostMissionSceneLayout(
      step,
      practiceContext,
      selectedChoice,
    );
    if (step.visual == LostMissionVisual.contacts) {
      return SingleChildScrollView(
        child: Column(
          children: [
            PracticeContactPicker(
              contacts: [
                for (final choice in step.choices)
                  if (choice.contactId != null)
                    PracticeContactChoice(
                      id: choice.id,
                      key: ValueKey('lost-choice-${choice.id}'),
                      label: practiceContext.contacts
                          .firstWhere(
                            (contact) => contact.id == choice.contactId,
                          )
                          .label,
                      avatar: lostActionIcon(choice.icon),
                    ),
              ],
              selectedId: selectedChoice?.id,
              onChoose: onChoice,
            ),
            if (layout.targets.isNotEmpty) _portraitScene(layout),
          ],
        ),
      );
    }
    return _portraitScene(layout);
  }

  Widget _portraitScene(LostMissionSceneLayout layout) => LayoutBuilder(
    builder: (context, constraints) {
      // Preserve object spacing in landscape instead of shrinking the canvas
      // until neighbouring 48 px controls overlap.
      final width = math.max(
        lostMissionMinimumSceneWidth,
        constraints.maxWidth,
      );
      final size = Size(width, width / lostMissionSceneSize.aspectRatio);
      Widget canvas = _sceneCanvas(layout, size);
      if (width > constraints.maxWidth) {
        canvas = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: canvas,
        );
      }
      return SingleChildScrollView(child: canvas);
    },
  );

  Widget _sceneCanvas(LostMissionSceneLayout layout, Size size) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: size.width,
      height: size.height,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Semantics(
              image: true,
              label: layout.description,
              child: ExcludeSemantics(
                child: layout.asset == null
                    ? const ColoredBox(color: BaseboundColors.cream)
                    : Image.asset(
                        layout.asset!,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/illustrations/street-practice-v2.png',
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => const CustomPaint(
                            painter: _SquareBackdropPainter(),
                          ),
                        ),
                      ),
              ),
            ),
            for (final object in layout.objects) _picturedObject(object, size),
            for (var index = 0; index < step.choices.length; index++)
              if (layout.targets[step.choices[index].id] case final bounds?)
                _target(size, bounds, step.choices[index], index),
          ],
        ),
      ),
    ),
  );

  Widget _picturedObject(LostSceneObject object, Size size) {
    final choice = step.choices
        .where((choice) => choice.id == object.choiceId)
        .firstOrNull;
    final rejected = rejectedChoiceIds.contains(object.choiceId);
    return Positioned.fromRect(
      rect: _scaledRect(object.bounds, size),
      child: ExcludeSemantics(
        child: Opacity(
          opacity: rejected ? .48 : 1,
          child: CustomPaint(
            foregroundPainter: choice == null
                ? null
                : LostSceneObjectOutline(
                    kind: object.kind,
                    gender: practiceContext.gender,
                    rejected: rejected,
                    selected: selectedChoice?.id == choice.id,
                    correct: choice.isCorrect,
                  ),
            child: LostSceneIllustration(
              object: object,
              gender: practiceContext.gender,
              photoLabel: choice?.label ?? practiceContext.meetingPointLabel,
            ),
          ),
        ),
      ),
    );
  }

  Widget _target(Size size, Rect bounds, LostMissionChoice choice, int index) {
    final rejected = rejectedChoiceIds.contains(choice.id);
    return Positioned.fromRect(
      rect: lostSceneHitRect(bounds, size),
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: SceneObjectTarget(
          key: ValueKey('lost-choice-${choice.id}'),
          label: choice.label,
          selected: selectedChoice?.id == choice.id,
          rejected: rejected,
          onTap: onChoice == null || rejected
              ? null
              : () => onChoice!(choice.id),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

Rect _scaledRect(Rect bounds, Size size) => Rect.fromLTWH(
  bounds.left * size.width,
  bounds.top * size.height,
  bounds.width * size.width,
  bounds.height * size.height,
);

/// Expands a small object around its centre without moving its drawn outline.
/// The portrait scrolls vertically; fitting never crops its coordinate space.
Rect lostSceneHitRect(Rect bounds, Size size) {
  final pictured = _scaledRect(bounds, size);
  final width = math.max(48.0, pictured.width);
  final height = math.max(48.0, pictured.height);
  return Rect.fromLTWH(
    (pictured.center.dx - width / 2).clamp(0.0, size.width - width),
    (pictured.center.dy - height / 2).clamp(0.0, size.height - height),
    width,
    height,
  );
}

/// Local asset failure preserves the same calm portrait environment.
class _SquareBackdropPainter extends CustomPainter {
  const _SquareBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = BaseboundColors.sky);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .34, size.width, size.height * .66),
      Paint()..color = BaseboundColors.cream,
    );
    final wall = Paint()..color = const Color(0xFFD6D0C3);
    for (final left in [0.0, .36, .73]) {
      canvas.drawRect(
        Rect.fromLTWH(
          left * size.width,
          size.height * .12,
          size.width * .29,
          size.height * .22,
        ),
        wall,
      );
    }
  }

  @override
  bool shouldRepaint(_SquareBackdropPainter oldDelegate) => false;
}
