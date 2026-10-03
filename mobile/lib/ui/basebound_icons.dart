/// Small, local vector illustrations shared by practice and adult setup.
/// Callers own labels and actions; the drawings contain no font glyphs.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'basebound_icon_art.dart';
import 'basebound_icon_name.dart';
import 'basebound_control_icon_art.dart';

export 'basebound_icon_name.dart';
import 'icons/speaker.dart';
import 'icons/wait.dart';
import 'icons/idea.dart';
import 'icons/phone.dart';
import 'icons/message.dart';
import 'icons/message_read.dart';
import 'icons/help.dart';
import 'icons/no_signal.dart';
import 'icons/edit.dart';
import 'icons/delete.dart';
import 'icons/lock.dart';
import 'icons/alert.dart';
import 'icons/child.dart';
import 'icons/adult.dart';
import 'icons/family.dart';
import 'icons/add_adult.dart';
import 'icons/mother.dart';
import 'icons/father.dart';
import 'icons/grandparent.dart';
import 'icons/home.dart';
import 'icons/park.dart';
import 'icons/school.dart';
import 'icons/shelter.dart';
import 'icons/bus_stop.dart';
import 'icons/window.dart';
import 'icons/door.dart';
import 'icons/hallway.dart';
import 'icons/living_room.dart';
import 'icons/bedroom.dart';
import 'icons/kitchen.dart';

class BaseboundIcon extends StatelessWidget {
  const BaseboundIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
    this.calm = false,
  });

  final BaseboundIconName name;
  final double size;
  final Color? color;
  final bool calm;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _IconPainter(name, color, calm)),
      ),
    ),
  );
}

class BaseboundBackButton extends StatelessWidget {
  const BaseboundBackButton({
    super.key,
    this.onPressed,
    this.tooltip,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final String? tooltip;
  final bool enabled;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: enabled
        ? onPressed ?? () => Navigator.of(context).maybePop()
        : null,
    tooltip: tooltip ?? MaterialLocalizations.of(context).backButtonTooltip,
    icon: const BaseboundIcon(BaseboundIconName.back),
  );
}

/// Paint into any rectangle; all motifs share a transparent 48-unit artboard.
void paintBaseboundIcon(
  Canvas canvas,
  Rect bounds,
  BaseboundIconName name, {
  Color? color,
  bool calm = false,
}) {
  final side = math.min(bounds.width, bounds.height);
  if (side <= 0) return;
  canvas.save();
  canvas.translate(bounds.center.dx - side / 2, bounds.center.dy - side / 2);
  canvas.scale(side / 48);
  final draw = _storyDrawings[name];
  if (draw != null) {
    draw(StoryIconArt(canvas, color: color, calm: calm));
  } else {
    canvas.scale(2);
    paintBaseboundControlIcon(canvas, name, color: color, calm: calm);
  }
  canvas.restore();
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.name, this.color, this.calm);

  final BaseboundIconName name;
  final Color? color;
  final bool calm;

  @override
  void paint(Canvas canvas, Size size) => paintBaseboundIcon(
    canvas,
    Offset.zero & size,
    name,
    color: color,
    calm: calm,
  );

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) =>
      oldDelegate.name != name ||
      oldDelegate.color != color ||
      oldDelegate.calm != calm;
}

final _storyDrawings = <BaseboundIconName, void Function(StoryIconArt)>{
  BaseboundIconName.speaker: drawSpeaker,
  BaseboundIconName.wait: drawWait,
  BaseboundIconName.idea: drawIdea,
  BaseboundIconName.phone: drawPhone,
  BaseboundIconName.message: drawMessage,
  BaseboundIconName.messageRead: drawMessageRead,
  BaseboundIconName.help: drawHelp,
  BaseboundIconName.noSignal: drawNoSignal,
  BaseboundIconName.edit: drawEdit,
  BaseboundIconName.delete: drawDelete,
  BaseboundIconName.lock: drawLock,
  BaseboundIconName.alert: drawAlert,
  BaseboundIconName.child: drawChild,
  BaseboundIconName.adult: drawAdult,
  BaseboundIconName.family: drawFamily,
  BaseboundIconName.addAdult: drawAddAdult,
  BaseboundIconName.mother: drawMother,
  BaseboundIconName.father: drawFather,
  BaseboundIconName.grandparent: drawGrandparent,
  BaseboundIconName.home: drawHome,
  BaseboundIconName.park: drawPark,
  BaseboundIconName.school: drawSchool,
  BaseboundIconName.shelter: drawShelter,
  BaseboundIconName.busStop: drawBusStop,
  BaseboundIconName.window: drawWindow,
  BaseboundIconName.door: drawDoor,
  BaseboundIconName.hallway: drawHallway,
  BaseboundIconName.livingRoom: drawLivingRoom,
  BaseboundIconName.bedroom: drawBedroom,
  BaseboundIconName.kitchen: drawKitchen,
};
