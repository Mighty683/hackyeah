import 'dart:typed_data';

import 'package:do_bazy/audio/training_cue.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final cue in TrainingCue.bundled.values) {
    test(
      '${cue.name} produces a browser PCM excerpt from the real asset',
      () async {
        final source = await rootBundle.load(cue.asset);
        final wav = ByteData.sublistView(cue.browserWav(source));
        final rate = wav.getUint32(24, Endian.little);
        expect(wav.getUint16(20, Endian.little), 1); // PCM, not A-law.
        expect(wav.getUint16(22, Endian.little), 1);
        expect(wav.getUint16(34, Endian.little), 16);
        expect(wav.lengthInBytes, 44 + rate * cue.durationMs ~/ 1000 * 2);
        expect(wav.getUint32(40, Endian.little), wav.lengthInBytes - 44);
        final samples = [
          for (var at = 44; at < wav.lengthInBytes; at += 2)
            wav.getInt16(at, Endian.little),
        ];
        expect(samples.any((sample) => sample.abs() > 100), isTrue);
        if (cue.name == 'busy' || cue.name == 'noise') {
          expect(
            wav.getInt16(44 + 2000, Endian.little),
            source.getInt16(44 + 2000, Endian.little),
          );
        }
      },
    );
  }

  test('invalid recordings fail rather than generating silent audio', () {
    expect(
      () => TrainingCue.bundled['alarm']!.browserWav(ByteData(44)),
      throwsFormatException,
    );
  });
}
