import 'package:flutter/material.dart';

enum MissionRegion { instruction, scene, actions }

/// Readable content takes priority; the uncropped illustration takes the rest.
/// Accessibility text can scroll without moving the primary button.
class MissionViewportLayout extends MultiChildLayoutDelegate {
  MissionViewportLayout();

  @override
  void performLayout(Size size) {
    final instruction = layoutChild(
      MissionRegion.instruction,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height * .4,
      ),
    );
    final actions = layoutChild(
      MissionRegion.actions,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: (size.height - instruction.height) * .8,
      ),
    );
    final sceneHeight = (size.height - instruction.height - actions.height - 16)
        .clamp(0.0, size.height);
    layoutChild(
      MissionRegion.scene,
      BoxConstraints.tight(Size(size.width, sceneHeight)),
    );
    positionChild(MissionRegion.instruction, Offset.zero);
    positionChild(MissionRegion.scene, Offset(0, instruction.height + 8));
    positionChild(
      MissionRegion.actions,
      Offset(0, size.height - actions.height),
    );
  }

  @override
  bool shouldRelayout(MissionViewportLayout oldDelegate) => false;
}
