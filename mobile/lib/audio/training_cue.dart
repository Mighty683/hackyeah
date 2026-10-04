import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// The same brief, quiet teaching excerpts used by Android.
class TrainingCue {
  const TrainingCue(this.name, this.offsetMs, this.durationMs, this.volume);

  final String name;
  final int offsetMs;
  final int durationMs;
  final double volume;

  String get asset => 'assets/audio/mission01/$name.wav';

  static const bundled = {
    'alarm': TrainingCue('alarm', 6000, 4000, 0.1),
    'all_clear': TrainingCue('all_clear', 2000, 3000, 0.1),
    'noise': TrainingCue('noise', 0, 1000, 0.7),
    'busy': TrainingCue('busy', 0, 2500, 0.4),
  };

  /// Decode in memory because browsers cannot reliably play G.711 A-law WAV.
  /// Original bundled recordings stay unchanged; only the excerpt is played.
  Uint8List browserWav(ByteData source) {
    String tag(int at) =>
        ascii.decode([for (var i = at; i < at + 4; i++) source.getUint8(i)]);
    if (source.lengthInBytes < 12 || tag(0) != 'RIFF' || tag(8) != 'WAVE') {
      throw const FormatException('Invalid training WAV');
    }
    var format = 0;
    var channels = 0;
    var rate = 0;
    var bits = 0;
    var dataStart = 0;
    var dataLength = 0;
    for (var at = 12; at + 8 <= source.lengthInBytes;) {
      final length = source.getUint32(at + 4, Endian.little);
      final start = at + 8;
      if (start + length > source.lengthInBytes) {
        throw const FormatException('Truncated training WAV');
      }
      final id = tag(at);
      if (id == 'fmt ' && length >= 16) {
        format = source.getUint16(start, Endian.little);
        channels = source.getUint16(start + 2, Endian.little);
        rate = source.getUint32(start + 4, Endian.little);
        bits = source.getUint16(start + 14, Endian.little);
      }
      if (id == 'data') {
        dataStart = start;
        dataLength = length;
        break;
      }
      at = start + length + length % 2;
    }
    if (channels != 1 ||
        rate <= 0 ||
        !((format == 6 && bits == 8) || (format == 1 && bits == 16))) {
      throw const FormatException('Unsupported training WAV format');
    }
    final first = rate * offsetMs ~/ 1000;
    final count = min(
      rate * durationMs ~/ 1000,
      dataLength ~/ (bits ~/ 8) - first,
    );
    if (count <= 0) throw const FormatException('Empty training excerpt');
    final output = ByteData(44 + count * 2);
    void writeTag(int at, String value) {
      final bytes = ascii.encode(value);
      for (var i = 0; i < bytes.length; i++) {
        output.setUint8(at + i, bytes[i]);
      }
    }

    writeTag(0, 'RIFF');
    output.setUint32(4, 36 + count * 2, Endian.little);
    writeTag(8, 'WAVE');
    writeTag(12, 'fmt ');
    output.setUint32(16, 16, Endian.little);
    output.setUint16(20, 1, Endian.little);
    output.setUint16(22, 1, Endian.little);
    output.setUint32(24, rate, Endian.little);
    output.setUint32(28, rate * 2, Endian.little);
    output.setUint16(32, 2, Endian.little);
    output.setUint16(34, 16, Endian.little);
    writeTag(36, 'data');
    output.setUint32(40, count * 2, Endian.little);
    for (var i = 0; i < count; i++) {
      final at = dataStart + (first + i) * (bits ~/ 8);
      final sample = format == 6
          ? _decodeALaw(source.getUint8(at))
          : source.getInt16(at, Endian.little);
      output.setInt16(44 + i * 2, sample, Endian.little);
    }
    return output.buffer.asUint8List();
  }

  static int _decodeALaw(int encoded) {
    final value = encoded ^ 0x55;
    final exponent = (value & 0x70) >> 4;
    final mantissa = (value & 0x0f) << 4;
    final amplitude = exponent == 0
        ? mantissa + 8
        : (mantissa + 264) << (exponent - 1);
    return value & 0x80 != 0 ? amplitude : -amplitude;
  }
}
