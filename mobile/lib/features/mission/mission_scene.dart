import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import 'mission_choice_card.dart';

bool missionUsesSceneChoices(MissionVisual visual) =>
    visual == MissionVisual.room || visual == MissionVisual.apartment;

/// Friendly fictional scenes. Room targets are also accessible touch controls.
class MissionScene extends StatelessWidget {
  const MissionScene({
    super.key,
    required this.visual,
    this.choices = const [],
    this.selectedChoice,
    this.onChoose,
  });

  final MissionVisual visual;
  final List<MissionChoice> choices;
  final MissionChoice? selectedChoice;
  final ValueChanged<String>? onChoose;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: AspectRatio(
        aspectRatio: switch (visual) {
          MissionVisual.room when scale <= 1.25 => 1,
          MissionVisual.alarm || MissionVisual.allClear => 1.5,
          _ => scale > 1.4 ? 1.05 : 1.25,
        },
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  label: _sceneDescription(visual, selectedChoice),
                  image: true,
                  child: _SceneArtwork(
                    visual: visual,
                    selectedChoice: selectedChoice,
                  ),
                ),
              ),
              if (missionUsesSceneChoices(visual))
                ...choices.map((choice) {
                  final rect = _targetRect(visual, choice.icon);
                  return Positioned(
                    left: rect.left * constraints.maxWidth,
                    top: rect.top * constraints.maxHeight,
                    width: rect.width * constraints.maxWidth,
                    height: rect.height * constraints.maxHeight,
                    child: _RoomTarget(
                      choice: choice,
                      illustrated:
                          visual == MissionVisual.room &&
                          choice.icon == MissionActionIcon.interior,
                      selected: selectedChoice?.id == choice.id,
                      onTap: onChoose == null
                          ? null
                          : () => onChoose!(choice.id),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Artwork is decorative; touch targets and spoken descriptions stay native.
class _SceneArtwork extends StatelessWidget {
  const _SceneArtwork({required this.visual, required this.selectedChoice});

  final MissionVisual visual;
  final MissionChoice? selectedChoice;

  String? get _asset => switch (visual) {
    MissionVisual.alarm ||
    MissionVisual.allClear => 'assets/illustrations/home-practice.png',
    MissionVisual.room =>
      selectedChoice == null ? 'assets/illustrations/home-practice.png' : null,
    MissionVisual.sheltered || MissionVisual.quiet =>
      selectedChoice?.isCorrect == false
          ? null
          : 'assets/illustrations/hallway-practice.png',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final paintedScene = CustomPaint(
      painter: _MissionScenePainter(visual, selectedChoice),
    );
    final fallback = visual == MissionVisual.room
        ? Align(
            alignment: Alignment.topCenter,
            child: AspectRatio(aspectRatio: 1.5, child: paintedScene),
          )
        : paintedScene;
    final asset = _asset;
    if (asset == null) {
      return ColoredBox(color: BaseboundColors.peach, child: fallback);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [BaseboundColors.cream, BaseboundColors.peach],
            ),
          ),
        ),
        Image.asset(
          asset,
          fit: asset == 'assets/illustrations/home-practice.png'
              ? BoxFit.contain
              : BoxFit.cover,
          alignment: asset == 'assets/illustrations/home-practice.png'
              ? Alignment.topCenter
              : Alignment.center,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => fallback,
        ),
        if (visual != MissionVisual.room)
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220F2568),
                    blurRadius: 18,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                switch (visual) {
                  MissionVisual.alarm => Icons.notifications_active_rounded,
                  MissionVisual.allClear => Icons.check_circle_rounded,
                  _ => Icons.hourglass_bottom_rounded,
                },
                color: visual == MissionVisual.allClear
                    ? BaseboundColors.green
                    : BaseboundColors.blue,
                size: 38,
              ),
            ),
          ),
      ],
    );
  }
}

Rect _targetRect(MissionVisual visual, MissionActionIcon icon) {
  if (visual == MissionVisual.room) {
    return switch (icon) {
      MissionActionIcon.window => const Rect.fromLTWH(.025, .67, .30, .30),
      MissionActionIcon.door => const Rect.fromLTWH(.675, .67, .30, .30),
      _ => const Rect.fromLTWH(.35, .67, .30, .30),
    };
  }
  return switch (icon) {
    MissionActionIcon.livingRoom => const Rect.fromLTWH(.035, .075, .43, .37),
    MissionActionIcon.bedroom => const Rect.fromLTWH(.535, .075, .43, .37),
    MissionActionIcon.kitchen => const Rect.fromLTWH(.035, .545, .43, .37),
    _ => const Rect.fromLTWH(.535, .545, .43, .37),
  };
}

String _sceneDescription(MissionVisual visual, MissionChoice? choice) {
  if (choice?.icon == MissionActionIcon.window) {
    return 'The child has moved toward the window.';
  }
  if (choice?.icon == MissionActionIcon.door ||
      choice?.icon == MissionActionIcon.leave) {
    return 'The child has moved toward the door.';
  }
  return switch (visual) {
    MissionVisual.alarm => 'A child playing at home. A phone shows an alarm.',
    MissionVisual.room => 'A room with a window, an inside area, and a door.',
    MissionVisual.apartment => 'A home seen from above. Three rooms have windows. The hallway is inside.',
    MissionVisual.twoWalls =>
      'The child, one wall, another wall, then outside.',
    MissionVisual.contacts => 'Pretend family faces on the child’s phone.',
    MissionVisual.communication => 'A pretend phone with a call and a message.',
    MissionVisual.message => 'A pretend message and a reply from an adult.',
    MissionVisual.sheltered ||
    MissionVisual.quiet => 'The child is waiting in an inside room.',
    MissionVisual.allClear => 'A pretend phone shows the all-clear.',
    MissionVisual.recall => 'Pictures of the six actions practiced.',
    MissionVisual.street =>
      'A street with home and school far away and a solid building nearby.',
    MissionVisual.getDown =>
      choice?.isCorrect == true
          ? 'The child has got down low.'
          : 'The child is standing outdoors.',
    MissionVisual.protectHead =>
      choice?.isCorrect == true
          ? 'The child covers their head with both arms.'
          : 'The child is down low with their arms by their side.',
  };
}

class _RoomTarget extends StatelessWidget {
  const _RoomTarget({
    required this.choice,
    required this.selected,
    required this.onTap,
    this.illustrated = false,
  });

  final MissionChoice choice;
  final bool selected;
  final VoidCallback? onTap;
  final bool illustrated;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? (choice.isCorrect ? BaseboundColors.green : BaseboundColors.coral)
        : BaseboundColors.blue;
    return Semantics(
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      selected: selected,
      label: choice.label,
      child: ExcludeSemantics(
        child: Material(
          elevation: selected ? 8 : 3,
          shadowColor: selected
              ? accent.withValues(alpha: .38)
              : BaseboundColors.ink.withValues(alpha: .16),
          color: selected
              ? (choice.isCorrect
                    ? BaseboundColors.greenLight
                    : BaseboundColors.coralLight)
              : Colors.white.withValues(alpha: .97),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: selected ? accent : Colors.white,
              width: selected ? 3 : 1.5,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (illustrated)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/illustrations/hallway-practice.png',
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                              errorBuilder: (_, _, _) => ColoredBox(
                                color: BaseboundColors.cream,
                                child: Icon(
                                  missionActionIcon(choice.icon),
                                  color: BaseboundColors.blue,
                                  size: 38,
                                ),
                              ),
                            ),
                            if (!selected)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    missionActionIcon(choice.icon),
                                    color: BaseboundColors.blue,
                                    size: 24,
                                  ),
                                ),
                              ),
                            if (selected)
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _selectionIcon(accent),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: selected ? accent : BaseboundColors.sky,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selected
                            ? (choice.isCorrect
                                  ? Icons.check_rounded
                                  : Icons.close_rounded)
                            : missionActionIcon(choice.icon),
                        size: 30,
                        color: selected ? Colors.white : BaseboundColors.blue,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      _shortLabel(choice),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: BaseboundColors.ink,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectionIcon(Color accent) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
    child: Icon(
      choice.isCorrect ? Icons.check_rounded : Icons.close_rounded,
      color: Colors.white,
      size: 30,
    ),
  );
}

String _shortLabel(MissionChoice choice) => switch (choice.icon) {
  MissionActionIcon.window => 'Window',
  MissionActionIcon.door => 'Outside',
  MissionActionIcon.interior => 'Inside',
  MissionActionIcon.hallway => 'Hallway',
  _ => choice.label,
};

class _MissionScenePainter extends CustomPainter {
  _MissionScenePainter(this.visual, this.selectedChoice);

  final MissionVisual visual;
  final MissionChoice? selectedChoice;
  static const ink = BaseboundColors.ink;
  static const wall = Color(0xFFC99E73);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 600, size.height / 400);
    _box(canvas, const Rect.fromLTWH(0, 0, 600, 400), BaseboundColors.peach);
    switch (visual) {
      case MissionVisual.apartment:
        _apartment(canvas);
      case MissionVisual.twoWalls:
        _walls(canvas);
      case MissionVisual.street:
        _street(canvas);
      case MissionVisual.contacts:
      case MissionVisual.communication:
      case MissionVisual.message:
        _communication(canvas);
      case MissionVisual.recall:
        _recall(canvas);
      case MissionVisual.getDown:
      case MissionVisual.protectHead:
        _outdoorAction(canvas);
      case MissionVisual.sheltered:
      case MissionVisual.quiet:
        if (selectedChoice?.isCorrect == false) {
          _room(canvas);
        } else {
          _sheltered(canvas);
        }
      default:
        _room(canvas);
    }
    canvas.restore();
  }

  void _box(Canvas canvas, Rect rect, Color color, {double radius = 12}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      Paint()..color = color,
    );
  }

  void _line(
    Canvas canvas,
    Offset a,
    Offset b, {
    Color color = ink,
    double width = 5,
  }) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _icon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size, {
    Color color = ink,
  }) {
    final text = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
  }

  void _window(Canvas canvas, Rect rect) {
    _box(canvas, rect, const Color(0xFFB6DDEA), radius: 3);
    _line(
      canvas,
      Offset(rect.center.dx, rect.top),
      Offset(rect.center.dx, rect.bottom),
      color: wall,
      width: 6,
    );
    _line(
      canvas,
      Offset(rect.left, rect.center.dy),
      Offset(rect.right, rect.center.dy),
      color: wall,
      width: 6,
    );
  }

  void _child(
    Canvas canvas,
    Offset feet, {
    bool down = false,
    bool protected = false,
  }) {
    final head = feet + Offset(0, down ? -25 : -60);
    canvas.drawCircle(head, 17, Paint()..color = const Color(0xFFF1C69B));
    _box(
      canvas,
      Rect.fromCenter(
        center: feet + Offset(0, down ? -6 : -24),
        width: down ? 56 : 32,
        height: down ? 22 : 42,
      ),
      const Color(0xFF467EAB),
    );
    _line(
      canvas,
      head + const Offset(-5, -13),
      head + const Offset(11, -12),
      width: 9,
    );
    canvas.drawCircle(head + const Offset(-5, 0), 2, Paint()..color = ink);
    canvas.drawCircle(head + const Offset(5, 0), 2, Paint()..color = ink);
    if (protected) {
      _line(
        canvas,
        head + const Offset(-23, 6),
        head + const Offset(-9, -21),
        color: const Color(0xFFF1C69B),
        width: 10,
      );
      _line(
        canvas,
        head + const Offset(23, 6),
        head + const Offset(9, -21),
        color: const Color(0xFFF1C69B),
        width: 10,
      );
    }
    if (!down) {
      _line(
        canvas,
        feet + const Offset(-8, -3),
        feet + const Offset(-8, 9),
        width: 8,
      );
      _line(
        canvas,
        feet + const Offset(8, -3),
        feet + const Offset(8, 9),
        width: 8,
      );
    }
  }

  void _room(Canvas canvas) {
    _box(
      canvas,
      const Rect.fromLTWH(25, 38, 550, 310),
      const Color(0xFFF8ECD8),
    );
    _box(
      canvas,
      const Rect.fromLTWH(25, 325, 550, 38),
      const Color(0xFFD6BD93),
    );
    _window(canvas, const Rect.fromLTWH(45, 54, 115, 85));
    _box(
      canvas,
      const Rect.fromLTWH(448, 64, 95, 175),
      const Color(0xFFC69A71),
    );
    canvas.drawCircle(const Offset(523, 159), 5, Paint()..color = ink);
    _icon(
      canvas,
      Icons.weekend,
      const Offset(156, 266),
      90,
      color: const Color(0xFF8AADA0),
    );
    var x = visual == MissionVisual.room ? 215.0 : 300.0;
    if (selectedChoice?.icon == MissionActionIcon.interior) x = 340;
    if (selectedChoice?.icon == MissionActionIcon.window) x = 105;
    if (selectedChoice?.icon == MissionActionIcon.door ||
        selectedChoice?.icon == MissionActionIcon.leave) {
      x = 490;
    }
    _child(canvas, Offset(x, 317));
    if (visual == MissionVisual.alarm || visual == MissionVisual.allClear) {
      _phone(
        canvas,
        const Offset(340, 178),
        visual == MissionVisual.alarm
            ? Icons.notifications_active
            : Icons.check_circle_outline,
      );
    }
    if (visual == MissionVisual.sheltered || visual == MissionVisual.quiet) {
      _box(
        canvas,
        const Rect.fromLTWH(220, 40, 180, 200),
        const Color(0xFFE3EEDD),
      );
      _icon(
        canvas,
        visual == MissionVisual.quiet ? Icons.hourglass_empty : Icons.home,
        const Offset(308, 155),
        72,
      );
    }
  }

  void _apartment(Canvas canvas) {
    _box(canvas, const Rect.fromLTWH(10, 15, 580, 370), wall);
    _box(
      canvas,
      const Rect.fromLTWH(24, 29, 260, 150),
      const Color(0xFFF4E7C9),
    );
    _box(
      canvas,
      const Rect.fromLTWH(316, 29, 260, 150),
      const Color(0xFFEBDCDF),
    );
    _box(
      canvas,
      const Rect.fromLTWH(24, 219, 260, 150),
      const Color(0xFFDCE7EB),
    );
    _box(
      canvas,
      const Rect.fromLTWH(316, 219, 260, 150),
      const Color(0xFFDDECD9),
    );
    _window(canvas, const Rect.fromLTWH(70, 19, 100, 16));
    _window(canvas, const Rect.fromLTWH(392, 19, 100, 16));
    _window(canvas, const Rect.fromLTWH(15, 255, 17, 90));
    _icon(canvas, Icons.weekend, const Offset(145, 103), 65);
    _icon(canvas, Icons.bed, const Offset(442, 103), 65);
    _icon(canvas, Icons.countertops, const Offset(145, 295), 65);
    final feet = switch (selectedChoice?.icon) {
      MissionActionIcon.livingRoom => const Offset(145, 148),
      MissionActionIcon.bedroom => const Offset(442, 148),
      MissionActionIcon.kitchen => const Offset(145, 337),
      _ => const Offset(300, 219),
    };
    _child(canvas, feet);
    _line(
      canvas,
      const Offset(287, 191),
      const Offset(314, 191),
      color: const Color(0xFFE9F0E6),
      width: 25,
    );
  }

  void _walls(Canvas canvas) {
    _box(
      canvas,
      const Rect.fromLTWH(20, 50, 260, 290),
      const Color(0xFFF8ECD8),
    );
    _box(
      canvas,
      const Rect.fromLTWH(285, 50, 115, 290),
      const Color(0xFFE0ECE0),
    );
    _box(
      canvas,
      const Rect.fromLTWH(422, 50, 160, 290),
      const Color(0xFFCEE6EE),
    );
    _box(canvas, const Rect.fromLTWH(270, 35, 24, 330), wall);
    _box(canvas, const Rect.fromLTWH(395, 35, 24, 330), wall);
    _child(canvas, const Offset(150, 259));
    _icon(
      canvas,
      Icons.park,
      const Offset(506, 225),
      95,
      color: const Color(0xFF638B61),
    );
    _icon(canvas, Icons.arrow_forward, const Offset(225, 206), 32);
    _icon(canvas, Icons.arrow_forward, const Offset(345, 206), 32);
    _icon(canvas, Icons.arrow_forward, const Offset(452, 206), 32);
    _icon(canvas, Icons.filter_1, const Offset(280, 80), 30);
    _icon(canvas, Icons.filter_2, const Offset(406, 80), 30);
  }

  void _sheltered(Canvas canvas) {
    _box(canvas, const Rect.fromLTWH(30, 30, 540, 340), wall);
    _box(
      canvas,
      const Rect.fromLTWH(50, 50, 500, 300),
      const Color(0xFFF8ECD8),
    );
    _box(
      canvas,
      const Rect.fromLTWH(76, 269, 445, 65),
      const Color(0xFFD5E6DB),
    );
    _child(canvas, const Offset(280, 292));
    _icon(canvas, Icons.meeting_room, const Offset(143, 156), 82);
    _phone(canvas, const Offset(437, 182), Icons.hourglass_empty);
  }

  void _phone(Canvas canvas, Offset center, IconData icon) {
    _box(
      canvas,
      Rect.fromCenter(center: center, width: 88, height: 140),
      ink,
      radius: 16,
    );
    _box(
      canvas,
      Rect.fromCenter(
        center: center + const Offset(0, -4),
        width: 72,
        height: 111,
      ),
      Colors.white,
    );
    _icon(canvas, icon, center, 42, color: const Color(0xFF46775B));
    canvas.drawCircle(
      center + const Offset(0, 59),
      4,
      Paint()..color = Colors.white,
    );
  }

  void _communication(Canvas canvas) {
    _box(
      canvas,
      const Rect.fromLTWH(20, 28, 560, 345),
      const Color(0xFFF8ECD8),
    );
    _child(canvas, const Offset(110, 305));
    _phone(
      canvas,
      const Offset(288, 205),
      visual == MissionVisual.message
          ? Icons.mark_chat_read_outlined
          : Icons.chat_bubble_outline,
    );
    if (visual == MissionVisual.contacts) {
      _avatar(
        canvas,
        const Offset(178, 91),
        const Color(0xFFDCAD9F),
        Icons.face,
      );
      _avatar(
        canvas,
        const Offset(300, 91),
        const Color(0xFFA3C5CF),
        Icons.face,
      );
      _avatar(
        canvas,
        const Offset(422, 91),
        const Color(0xFFC5BBDA),
        Icons.face_6,
      );
      return;
    }
    _avatar(
      canvas,
      const Offset(446, 121),
      const Color(0xFFDCAD9F),
      Icons.face,
    );
    _box(canvas, const Rect.fromLTWH(373, 208, 180, 87), Colors.white);
    _icon(
      canvas,
      visual == MissionVisual.message
          ? Icons.hourglass_empty
          : Icons.phone_in_talk,
      const Offset(457, 251),
      54,
    );
    if (visual == MissionVisual.message) {
      _icon(
        canvas,
        Icons.check_circle_outline,
        const Offset(372, 150),
        36,
        color: const Color(0xFF46775B),
      );
    }
  }

  void _avatar(Canvas canvas, Offset center, Color color, IconData icon) {
    canvas.drawCircle(center, 43, Paint()..color = color);
    _icon(canvas, icon, center, 59);
  }

  void _street(Canvas canvas) {
    _box(canvas, const Rect.fromLTWH(0, 238, 600, 91), const Color(0xFFBCC6C7));
    _line(
      canvas,
      const Offset(20, 283),
      const Offset(570, 283),
      color: Colors.white,
      width: 4,
    );
    _building(canvas, const Rect.fromLTWH(28, 40, 108, 105), Icons.home);
    _building(canvas, const Rect.fromLTWH(428, 25, 137, 120), Icons.school);
    _building(canvas, const Rect.fromLTWH(235, 122, 141, 111), Icons.apartment);
    _icon(
      canvas,
      Icons.park,
      const Offset(82, 370),
      63,
      color: const Color(0xFF638B61),
    );
    _icon(canvas, Icons.directions_bus, const Offset(514, 360), 58);
    _line(
      canvas,
      const Offset(127, 160),
      const Offset(259, 217),
      color: wall,
      width: 3,
    );
    _line(
      canvas,
      const Offset(490, 162),
      const Offset(358, 220),
      color: wall,
      width: 3,
    );
    var feet = const Offset(311, 321);
    feet = switch (selectedChoice?.icon) {
      MissionActionIcon.shelter => const Offset(315, 245),
      MissionActionIcon.home => const Offset(97, 204),
      MissionActionIcon.school => const Offset(491, 210),
      MissionActionIcon.park => const Offset(159, 376),
      MissionActionIcon.busStop => const Offset(449, 376),
      _ => feet,
    };
    _child(canvas, feet);
  }

  void _building(Canvas canvas, Rect rect, IconData icon) {
    _box(canvas, rect, const Color(0xFFF6E7C8));
    _line(canvas, rect.topLeft, rect.topRight, width: 10, color: wall);
    _icon(canvas, icon, rect.center, 54);
  }

  void _outdoorAction(Canvas canvas) {
    _box(
      canvas,
      const Rect.fromLTWH(0, 270, 600, 130),
      const Color(0xFFBBC8C3),
    );
    _building(canvas, const Rect.fromLTWH(410, 63, 156, 160), Icons.apartment);
    final down =
        visual == MissionVisual.protectHead ||
        selectedChoice?.isCorrect == true;
    _child(
      canvas,
      Offset(270, down ? 296 : 263),
      down: down,
      protected:
          visual == MissionVisual.protectHead &&
          selectedChoice?.isCorrect == true,
    );
    _icon(
      canvas,
      visual == MissionVisual.getDown
          ? Icons.arrow_downward
          : Icons.health_and_safety_outlined,
      const Offset(141, 173),
      62,
      color: const Color(0xFF46775B),
    );
  }

  void _recall(Canvas canvas) {
    const icons = [
      Icons.notifications_active,
      Icons.window,
      Icons.meeting_room,
      Icons.chat_bubble_outline,
      Icons.hourglass_empty,
      Icons.check_circle_outline,
    ];
    for (var i = 0; i < icons.length; i++) {
      final x = 107.0 + (i % 3) * 192;
      final y = i < 3 ? 123.0 : 282.0;
      canvas.drawCircle(
        Offset(x, y),
        63,
        Paint()
          ..color = i.isEven
              ? const Color(0xFFD5E6DB)
              : const Color(0xFFF6E7C8),
      );
      if (i == 1) {
        _icon(canvas, Icons.window, Offset(x - 27, y), 40);
        _icon(canvas, Icons.arrow_forward, Offset(x + 24, y), 40);
      } else {
        _icon(canvas, icons[i], Offset(x, y), 62);
      }
      if (i != 2 && i != 5) {
        _icon(canvas, Icons.arrow_forward, Offset(x + 94, y), 28);
      }
    }
  }

  @override
  bool shouldRepaint(_MissionScenePainter oldDelegate) =>
      visual != oldDelegate.visual ||
      selectedChoice != oldDelegate.selectedChoice;
}
