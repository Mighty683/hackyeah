import 'package:flutter/material.dart';

import 'mission_home_plan_painter.dart';

/// Loads the bundled furniture atlas once; the native plan remains the fallback.
class MissionHomePlan extends StatefulWidget {
  const MissionHomePlan({super.key});

  @override
  State<MissionHomePlan> createState() => _MissionHomePlanState();
}

class _MissionHomePlanState extends State<MissionHomePlan> {
  ImageStream? _stream;
  ImageInfo? _furniture;
  late final _listener = ImageStreamListener(_loaded, onError: (_, _) {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = const AssetImage(
      'assets/illustrations/interior-furniture-v1.png',
    ).resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _loaded(ImageInfo info, bool synchronous) {
    _furniture?.dispose();
    setState(() => _furniture = info);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _furniture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: MissionHomePlanPainter(furniture: _furniture?.image),
  );
}
