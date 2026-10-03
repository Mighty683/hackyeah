import 'dart:async';

import 'package:flutter/foundation.dart';

import 'practice_audio.dart';

/// Owns playback state and cancels stale requests across screen lifecycle changes.
/// Screens retain their own instructions, progression and navigation decisions.
class PracticeNarrationController extends ChangeNotifier {
  PracticeNarrationController(this._audio, {this.recreateAudio});

  PracticeAudio _audio;
  final PracticeAudio Function()? recreateAudio;
  bool _ready = false;
  bool _initializing = true;
  bool _speaking = false;
  bool _foreground = true;
  bool _closed = false;
  int _request = 0;

  bool get ready => _ready;
  bool get initializing => _initializing;
  bool get speaking => _speaking;

  Future<void> initialize({bool retry = false}) async {
    if (_closed) return;
    final request = ++_request;
    _initializing = true;
    _speaking = false;
    notifyListeners();
    final recreate = recreateAudio;
    if (retry && recreate != null) {
      await _audio.dispose();
      if (_closed || request != _request) return;
      _audio = recreate();
    }
    var ready = false;
    try {
      ready = await _audio.initialize();
    } catch (_) {
      ready = false;
    }
    if (_closed || request != _request) return;
    _ready = ready;
    _initializing = false;
    notifyListeners();
  }

  Future<void> narrate(
    String text, {
    String? sound,
    VoidCallback? beforePlayback,
  }) async {
    if (_initializing || !_foreground || _closed) return;
    final request = ++_request;
    _speaking = _ready;
    notifyListeners();
    try {
      await _audio.stop();
      if (!_foreground || _closed || request != _request) return;
      beforePlayback?.call();
      if (_ready) {
        await _audio.narrate(text, sound: sound);
      } else if (sound != null) {
        await _audio.playCue(sound);
      }
    } catch (_) {
      if (!_closed && request == _request) _ready = false;
    } finally {
      if (!_closed && request == _request) {
        _speaking = false;
        notifyListeners();
      }
    }
  }

  void setForeground(bool foreground) {
    if (_closed) return;
    _foreground = foreground;
    if (foreground) return;
    // Initialization can finish in the background; playback waits for resume.
    if (!_initializing) ++_request;
    _speaking = false;
    notifyListeners();
    unawaited(_audio.stop());
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    ++_request;
    await _audio.dispose();
  }

  @override
  void dispose() {
    unawaited(close());
    super.dispose();
  }
}
