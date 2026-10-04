import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../widgets/child_character.dart';
import '../parent/data/family_plan.dart';
import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import 'mission_scene_backdrop.dart';
import 'mission_object_highlights.dart';
import 'mission_outdoor_action_scene.dart';
import 'mission_scene_layout.dart';
import 'scene_object_target.dart';

/// Uncropped practice art with accessible targets around scene objects.
class MissionScene extends StatelessWidget {
  const MissionScene({
    super.key,
    required this.visual,
    this.stepId,
    this.gender = ChildGender.girl,
    this.choices = const [],
    this.rejectedChoiceIds = const {},
    this.selectedChoice,
    this.onChoose,
  });

  final ChildGender gender;
  final MissionVisual visual;
  final String? stepId;
  final List<MissionChoice> choices;
  final Set<String> rejectedChoiceIds;
  final MissionChoice? selectedChoice;
  final ValueChanged<String>? onChoose;

  @override
  Widget build(BuildContext context) {
    final layout = missionSceneLayout(
      visual == MissionVisual.twoWalls ? null : stepId,
      visual,
    );
    if (stepId == 'outdoor_noise' ||
        stepId == 'outdoor_recover' ||
        visual == MissionVisual.getDown ||
        visual == MissionVisual.protectHead) {
      return MissionOutdoorActionScene(
        visual: visual,
        stepId: stepId,
        gender: gender,
        choices: choices,
        selectedChoice: selectedChoice,
        rejectedChoiceIds: rejectedChoiceIds,
        onChoose: onChoose,
        backdrop: MissionSceneBackdrop(
          layout: layout,
          visual: visual,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: missionSceneSize.aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) => FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  label: _sceneDescription(visual, selectedChoice),
                  image: true,
                  child: MissionSceneBackdrop(layout: layout, visual: visual),
                ),
                if (layout.childWidth > 0)
                  _character(context, constraints, layout),
                if (visual == MissionVisual.alarm ||
                    visual == MissionVisual.allClear)
                  _sceneSignal(constraints),
                IgnorePointer(
                  child: CustomPaint(
                    painter: MissionObjectHighlights(
                      layout: layout,
                      stepId: stepId,
                      choices: choices,
                      selectedChoice: selectedChoice,
                      rejectedChoiceIds: rejectedChoiceIds,
                      visual: visual,
                    ),
                  ),
                ),
                for (var index = 0; index < choices.length; index++)
                  if (layout.targets[choices[index].id] case final target?)
                    _target(constraints, target, choices[index], index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sceneSignal(BoxConstraints constraints) => Positioned(
    left: constraints.maxWidth * (visual == MissionVisual.alarm ? .07 : .405),
    top: constraints.maxHeight * (visual == MissionVisual.alarm ? .19 : .20),
    width: constraints.maxWidth * (visual == MissionVisual.alarm ? .11 : .19),
    height: constraints.maxHeight * (visual == MissionVisual.alarm ? .10 : .16),
    child: ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BaseboundColors.border),
        ),
        child: BaseboundIcon(
          visual == MissionVisual.alarm
              ? BaseboundIconName.alarm
              : BaseboundIconName.check,
          size: 34,
          color: visual == MissionVisual.alarm
              ? BaseboundColors.blue
              : BaseboundColors.green,
        ),
      ),
    ),
  );

  Widget _target(
    BoxConstraints constraints,
    Rect target,
    MissionChoice choice,
    int index,
  ) {
    final rejected =
        rejectedChoiceIds.contains(choice.id) ||
        (visual == MissionVisual.quiet &&
            selectedChoice != null &&
            choice.id == 'leave');
    final width = math.max(49.0, target.width * constraints.maxWidth);
    final height = math.max(49.0, target.height * constraints.maxHeight);
    return Positioned(
      left: math.min(
        target.left * constraints.maxWidth,
        constraints.maxWidth - width,
      ),
      top: math.min(
        target.top * constraints.maxHeight,
        constraints.maxHeight - height,
      ),
      width: width,
      height: height,
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: SceneObjectTarget(
          label: choice.label,
          selected: selectedChoice?.id == choice.id,
          rejected: rejected,
          onTap: onChoose == null || rejected
              ? null
              : () => onChoose!(choice.id),
          child:
              visual == MissionVisual.contacts ||
                  visual == MissionVisual.communication
              ? Padding(
                  padding: EdgeInsets.only(left: width * .31, right: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      choice.label,
                      style: const TextStyle(
                        color: BaseboundColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              : const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _character(
    BuildContext context,
    BoxConstraints constraints,
    MissionSceneLayout layout,
  ) {
    final destination =
        selectedChoice?.isCorrect == true ||
            selectedChoice?.continuesAfterFeedback == true
        ? layout.destinations[selectedChoice?.id]
        : null;
    final feet = destination ?? layout.childFeet;
    final extent =
        (destination == null
            ? layout.childWidth
            : layout.selectedChildWidth ?? layout.childWidth) *
        constraints.maxWidth;
    final pose = _characterPose(layout, selectedChoice, destination != null);
    return AnimatedPositioned(
      key: const ValueKey('mission-character'),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      left: feet.dx * constraints.maxWidth - extent / 2,
      top: feet.dy * constraints.maxHeight - extent,
      width: extent,
      height: extent,
      child: ExcludeSemantics(
        child: Transform.flip(
          flipX: destination != null && destination.dx < layout.childFeet.dx,
          child: ChildCharacter(pose: pose, gender: gender),
        ),
      ),
    );
  }
}

ChildPoseName _characterPose(
  MissionSceneLayout layout,
  MissionChoice? choice,
  bool moving,
) {
  if (layout.family == MissionVisual.protectHead) {
    return choice?.isCorrect == true
        ? ChildPoseName.protect
        : ChildPoseName.crouch;
  }
  if (layout.family == MissionVisual.getDown && choice?.isCorrect == true) {
    return ChildPoseName.crouch;
  }
  return moving ? ChildPoseName.walk : ChildPoseName.stand;
}

String _sceneDescription(MissionVisual visual, MissionChoice? choice) {
  if (visual == MissionVisual.street &&
      choice?.continuesAfterFeedback == true) {
    return 'Dziecko ruszyło ulicą i nadal jest na zewnątrz.';
  }
  if (choice?.isCorrect == false) choice = null;
  if (choice?.icon == MissionActionIcon.window) {
    return 'Dziecko podeszło do okna.';
  }
  if (choice?.icon == MissionActionIcon.door ||
      choice?.icon == MissionActionIcon.leave) {
    return 'Dziecko podeszło do drzwi.';
  }
  return switch (visual) {
    MissionVisual.alarm => 'Dziecko bawi się w domu. Za oknem słychać alarm.',
    MissionVisual.room => 'Pokój z oknem, wnętrzem i drzwiami.',
    MissionVisual.apartment =>
      'Dom widziany z góry. Trzy pokoje mają okna. Korytarz jest w środku.',
    MissionVisual.twoWalls =>
      'Dziecko, jedna ściana, druga ściana, a za nimi zewnętrzna część domu.',
    MissionVisual.contacts => 'Twarze rodziny na niby na telefonie dziecka.',
    MissionVisual.communication => 'Telefon na niby. Spróbuj zadzwonić raz, a potem wysłać SMS, jeśli nikt nie odbiera.',
    MissionVisual.message => 'Wiadomość na niby i odpowiedź osoby dorosłej.',
    MissionVisual.sheltered ||
    MissionVisual.quiet => 'Dziecko czeka w wewnętrznym pomieszczeniu.',
    MissionVisual.allClear => 'Telefon na niby pokazuje odwołanie alarmu.',
    MissionVisual.recall => 'Obrazki sześciu ćwiczonych czynności.',
    MissionVisual.street =>
      'Ulica z domem i szkołą w oddali oraz solidnym budynkiem w pobliżu.',
    MissionVisual.getDown =>
      choice?.isCorrect == true
          ? 'Dziecko położyło się nisko.'
          : 'Dziecko stoi na zewnątrz.',
    MissionVisual.protectHead =>
      choice?.isCorrect == true
          ? 'Dziecko osłania głowę obiema rękami.'
          : 'Dziecko jest nisko, z rękami wzdłuż ciała.',
  };
}
