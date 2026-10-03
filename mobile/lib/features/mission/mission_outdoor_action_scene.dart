import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../parent/data/family_plan.dart';
import 'air_raid_mission.dart';
import 'scene_object_target.dart';
import 'mission_outdoor_painters.dart';

/// Keeps the street in view while making each physical action recognisable.
/// The poses share a ground line and scale; a lower pose is actually lower.
class MissionOutdoorActionScene extends StatelessWidget {
  const MissionOutdoorActionScene({
    super.key,
    required this.visual,
    required this.stepId,
    required this.gender,
    required this.choices,
    required this.selectedChoice,
    required this.rejectedChoiceIds,
    required this.onChoose,
    required this.backdrop,
  });

  final MissionVisual visual;
  final String? stepId;
  final ChildGender gender;
  final List<MissionChoice> choices;
  final MissionChoice? selectedChoice;
  final Set<String> rejectedChoiceIds;
  final ValueChanged<String>? onChoose;
  final Widget backdrop;

  OutdoorPose _poseFor(String? choiceId) {
    if (stepId == 'outdoor_recover' || choiceId == 'protect_head') {
      return OutdoorPose.protected;
    }
    if (visual == MissionVisual.protectHead || choiceId == 'down') {
      return OutdoorPose.lowered;
    }
    return OutdoorPose.standing;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final stackChoices = width < 200;
      final targetWidth = stackChoices ? width - 32 : (width - 48) / 2;
      final poseHeight = math.min(targetWidth, 156.0);
      final contextHeight = width * .38;
      final desiredHeight = choices.isEmpty
          ? width * .93
          : contextHeight +
                (poseHeight + 16) * (stackChoices ? choices.length : 1) +
                (stackChoices ? 16 * (choices.length - 1) : 0) +
                32;
      final height = constraints.hasBoundedHeight
          ? math.min(desiredHeight, constraints.maxHeight)
          : desiredHeight;
      final scene = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: SizedBox(
              height: choices.isEmpty ? height : desiredHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(child: backdrop),
                  ExcludeSemantics(
                    child: CustomPaint(
                      painter: StreetForegroundPainter(
                        soundCue: stepId == 'outdoor_noise',
                      ),
                    ),
                  ),
                  if (choices.isEmpty)
                    _currentPose()
                  else
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Flex(
                          direction: stackChoices
                              ? Axis.vertical
                              : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (
                              var index = 0;
                              index < choices.length;
                              index++
                            ) ...[
                              if (index > 0)
                                const SizedBox(width: 16, height: 16),
                              SizedBox(
                                width: targetWidth,
                                child: FocusTraversalOrder(
                                  order: NumericFocusOrder(index.toDouble()),
                                  child: _PoseChoice(
                                    choice: choices[index],
                                    pose: _poseFor(choices[index].id),
                                    gender: gender,
                                    poseHeight: poseHeight,
                                    rejected: rejectedChoiceIds.contains(
                                      choices[index].id,
                                    ),
                                    onTap:
                                        onChoose == null ||
                                            rejectedChoiceIds.contains(
                                              choices[index].id,
                                            )
                                        ? null
                                        : () => onChoose!(choices[index].id),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      // When content scrolls, a downward gesture must scroll, never answer.
      if (visual != MissionVisual.getDown ||
          choices.isEmpty ||
          onChoose == null ||
          desiredHeight > height) {
        return scene;
      }
      var dragDistance = 0.0;
      var chosen = false;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => dragDistance = 0,
        onVerticalDragUpdate: (details) {
          dragDistance += details.delta.dy;
          if (!chosen && dragDistance >= 48) {
            chosen = true;
            onChoose!('down');
          }
        },
        child: scene,
      );
    },
  );

  Widget _currentPose() {
    final pose = _poseFor(selectedChoice?.id);
    final withAdult = stepId == 'outdoor_recover';
    return Semantics(
      image: true,
      label: withAdult
          ? 'A trusted adult is nearby. The child stays down with their head covered.'
          : switch (pose) {
              OutdoorPose.standing =>
                'The child is still outside on the same street.',
              OutdoorPose.lowered => 'The child is down low on the street.',
              OutdoorPose.protected =>
                'The child stays down and covers their head with both arms.',
            },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (withAdult)
            const FractionallySizedBox(
              alignment: Alignment(-.6, .55),
              widthFactor: .36,
              heightFactor: .7,
              child: CustomPaint(
                painter: OutdoorPosePainter(
                  OutdoorPose.standing,
                  ChildGender.boy,
                  helper: true,
                ),
              ),
            ),
          FractionallySizedBox(
            alignment: Alignment(withAdult ? .5 : 0, .7),
            widthFactor: .55,
            heightFactor: .57,
            child: CustomPaint(painter: OutdoorPosePainter(pose, gender)),
          ),
        ],
      ),
    );
  }
}

class _PoseChoice extends StatelessWidget {
  const _PoseChoice({
    required this.choice,
    required this.pose,
    required this.gender,
    required this.poseHeight,
    required this.onTap,
    required this.rejected,
  });

  final MissionChoice choice;
  final OutdoorPose pose;
  final ChildGender gender;
  final double poseHeight;
  final VoidCallback? onTap;
  final bool rejected;

  @override
  Widget build(BuildContext context) => SceneObjectTarget(
    label: choice.label,
    onTap: onTap,
    rejected: rejected,
    child: SizedBox(
      height: poseHeight + 16,
      width: double.infinity,
      child: CustomPaint(
        foregroundPainter: SceneObjectHalo(rejected: rejected),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: CustomPaint(painter: OutdoorPosePainter(pose, gender)),
        ),
      ),
    ),
  );
}
