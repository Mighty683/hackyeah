import 'dart:io';

import 'package:flutter/material.dart';

import '../../../ui/basebound_ui.dart';
import '../data/landmark.dart';

class LandmarkPin extends StatelessWidget {
  const LandmarkPin({
    required this.landmark,
    required this.photoDirectory,
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final Landmark landmark;
  final String photoDirectory;
  final bool selected;
  final ValueChanged<Landmark> onSelected;

  @override
  Widget build(BuildContext context) => FittedBox(
    child: SizedBox(
      width: 48,
      height: 56,
      child: Semantics(
        button: true,
        selected: selected,
        label: landmark.name,
        child: Tooltip(
          message: landmark.name,
          child: Material(
            color: selected ? BaseboundColors.green : BaseboundColors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelected(landmark),
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    if (landmark.photoName.isNotEmpty)
                      Expanded(
                        child: Image.file(
                          File('$photoDirectory/${landmark.photoName}'),
                          width: 48,
                          fit: BoxFit.cover,
                          cacheWidth: 120,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.photo_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: Text(
                          landmark.icon,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
