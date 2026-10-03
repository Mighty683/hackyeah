# Tuptu launcher icon

The approved app icon combines the friendly dinosaur guide with a compass.
The source images were generated with the built-in imagegen tool:

- `safe-path-icon.png`: approved full-color square icon.
- `safe-path-icon-foreground.png`: transparent foreground extracted from that icon.

Generation prompt: combine the original lime-green dinosaur mascot with the
blue-and-green compass. The smiling dinosaur holds a large cream compass with
both hands. Use navy outlines, a bright blue background, simple flat shapes,
and no text, shadows, or extra objects.

Extraction prompt: remove only the blue background, preserving the complete
dinosaur, compass, colors, expression, pose, scale, and placement; output true
transparent alpha.

Android resources in `android/app/src/main/res/` include legacy launcher icons
at 48, 72, 96, 144, and 192 pixels, plus adaptive foreground layers at 108, 162,
216, 324, and 432 pixels. Adaptive artwork is centered with its longest edge at
64 dp inside the 108 dp layer, within Android's 66 dp safe area. The adaptive
background uses the app's blue (`#0967DA`). Android 8+ uses the adaptive icon;
older versions use the legacy PNGs. PNG resizing and packaging used Pillow.

These are Android build assets, not Flutter runtime assets; they do not need
an entry in `pubspec.yaml`.
