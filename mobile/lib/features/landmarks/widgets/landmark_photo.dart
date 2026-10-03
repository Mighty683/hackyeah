import '../../../platform/photo_access.dart';

import 'package:flutter/material.dart';

import '../../../ui/basebound_ui.dart';

class LandmarkPhoto extends StatelessWidget {
  const LandmarkPhoto({
    required this.path,
    required this.label,
    this.assetPath,
    this.height = 180,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String path;
  final String label;
  final String? assetPath;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image(
      image: ResizeImage(
        assetPath == null ? photoImageProvider(path) : AssetImage(assetPath!),
        width: 900,
      ),
      height: height,
      width: double.infinity,
      fit: fit,
      semanticLabel: label,
      errorBuilder: (_, _, _) => Container(
        height: height,
        color: BaseboundColors.sky,
        alignment: Alignment.center,
        child: const Text('Photo unavailable'),
      ),
    ),
  );
}
