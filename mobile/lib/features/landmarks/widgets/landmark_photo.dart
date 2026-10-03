import 'dart:io';

import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';

class LandmarkPhoto extends StatelessWidget {
  const LandmarkPhoto({
    required this.path,
    required this.label,
    this.height = 180,
    super.key,
  });

  final String path;
  final String label;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.file(
      File(path),
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      cacheWidth: 900,
      semanticLabel: label,
      errorBuilder: (_, _, _) => Container(
        height: height,
        color: BaseboundColors.sky,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BaseboundIcon(BaseboundIconName.pin, size: 32),
            const SizedBox(height: 8),
            const Text('Photo unavailable'),
          ],
        ),
      ),
    ),
  );
}
