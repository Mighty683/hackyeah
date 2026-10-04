import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Offline narration and gentle sound cues for scenario practice and walking guidance.
///
/// Android needs an installed Polish voice that does not require a network.
/// Callers must provide an adult-supported fallback when [initialize] is false.
/// [playCue] works without an installed voice.
class PracticeAudio {
  PracticeAudio({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('basebound/mission_audio');

  final MethodChannel _channel;
  Future<bool>? _initialization;
  bool _disposed = false;
  int _generation = 0;

  Future<bool> initialize() {
    if (_disposed || kIsWeb) return Future.value(false);
    return _initialization ??= _initialize().then((ready) {
      if (!ready) _initialization = null;
      return ready;
    });
  }

  Future<bool> _initialize() async {
    try {
      final ready = await _channel.invokeMethod<bool>('initialize') ?? false;
      return !_disposed && ready;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Cancels the previous cue or narration before speaking this instruction.
  ///
  /// [sound] accepts the same cues as [playCue]. The returned future ends when
  /// playback finishes or is cancelled. Playback errors reach the caller.
  Future<void> narrate(String text, {String? sound}) async {
    if (_disposed || kIsWeb) return;
    final generation = ++_generation;
    if (!await initialize() || _disposed || generation != _generation) return;
    await _channel.invokeMethod<void>('narrate', {
      'text': text,
      'sound': sound,
    });
  }

  /// Plays a cue without requiring or initializing an offline narration voice.
  ///
  /// Supports the teaching cues `alarm`, `all_clear`, and `noise`, plus gentle
  /// interaction cues `select`, `action`, `success`, and `retry`. Each playback
  /// cancels the previous cue or narration and completes when stopped or done.
  Future<void> playCue(String sound) async {
    if (_disposed || kIsWeb) return;
    ++_generation;
    await _channel.invokeMethod<void>('narrate', {'text': '', 'sound': sound});
  }

  Future<void> stop() async {
    if (_disposed || kIsWeb) return;
    ++_generation;
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // Exiting the screen must remain possible if the native engine failed.
    } on MissingPluginException {
      // Other platforms do not provide the Android training audio engine.
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    ++_generation;
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('dispose');
    } on PlatformException {
      // The Android activity also releases audio when its engine is destroyed.
    } on MissingPluginException {
      // Keep lifecycle cleanup safe on unsupported platforms.
    }
  }
}
