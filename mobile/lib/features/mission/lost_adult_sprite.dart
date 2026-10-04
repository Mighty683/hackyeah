import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';

enum LostAdultPose { staff, stranger, parent, trustedAdult }

/// Separate people sprites keep the fictional setting and choices reusable.
class LostAdultSprite extends StatelessWidget {
  const LostAdultSprite({super.key, required this.pose});

  final LostAdultPose pose;

  static const asset = 'assets/illustrations/lost-adults-v1.png';
  static const _sheetExtent = 1254.0;
  static const _sourceRects = [
    Rect.fromLTRB(260, 16, 562, 615),
    Rect.fromLTRB(703, 2, 1028, 615),
    Rect.fromLTRB(224, 642, 576, 1244),
    Rect.fromLTRB(816, 616, 1032, 1244),
  ];

  @override
  Widget build(BuildContext context) {
    final source = _sourceRects[pose.index];
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: source.width,
          height: source.height,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: -source.left,
                  top: -source.top,
                  width: _sheetExtent,
                  height: _sheetExtent,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => Stack(
                      children: [
                        Positioned.fromRect(
                          rect: source,
                          child: BaseboundIcon(
                            pose == LostAdultPose.parent
                                ? BaseboundIconName.mother
                                : BaseboundIconName.adult,
                            size: source.shortestSide,
                          ),
                        ),
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
  }
}
