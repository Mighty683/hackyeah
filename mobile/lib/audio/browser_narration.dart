import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/services.dart';

import 'training_cue.dart';

@JS('window.speechSynthesis')
external _SpeechSynthesis? get _synthesis;

@JS('console.warn')
external void _warn(String message);

extension type _SpeechSynthesis(JSObject _) implements JSObject {
  external JSArray<_Voice> getVoices();
  external void addEventListener(String type, JSFunction listener);
  external void removeEventListener(String type, JSFunction listener);
  external void speak(_Utterance utterance);
  external void cancel();
}

extension type _Voice(JSObject _) implements JSObject {
  external String get name;
  external String get lang;
  external bool get localService;
}

extension type _SpeechError(JSObject _) implements JSObject {
  external String get error;
}

@JS('SpeechSynthesisUtterance')
extension type _Utterance._(JSObject _) implements JSObject {
  external _Utterance(String text);
  external set lang(String value);
  external set rate(double value);
  external set voice(_Voice value);
  external set onstart(JSFunction? value);
  external set onend(JSFunction? value);
  external set onerror(JSFunction? value);
}

@JS('Audio')
extension type _CueAudio._(JSObject _) implements JSObject {
  external _CueAudio(String src);
  external set volume(double value);
  external set onended(JSFunction? value);
  external set onerror(JSFunction? value);
  external JSPromise<JSAny?> play();
  external void pause();
}

/// Browser-provided Polish narration; local voices are preferred, not required.
/// Remote voices may require connectivity. Teaching cues use local assets.
class BrowserNarration {
  int _cueRequest = 0;
  _CueAudio? _cue;
  Completer<void>? _cuePlayback;
  Timer? _cueTimeout;
  _Voice? _voice;
  _Utterance? _utterance;
  Completer<void>? _playback;
  Timer? _timeout;
  Completer<bool>? _voiceLoading;
  Timer? _voiceTimeout;

  void _reportUnavailable(_SpeechSynthesis synthesis) {
    final voices = synthesis.getVoices().toDart;
    final available = voices.map((voice) => '${voice.name} (${voice.lang})');
    _warn(
      '[Tuptu speech] No Polish voice available. '
      'Browser voices: ${voices.isEmpty ? "none" : available.join(", ")}. '
      'Retry after a Polish voice becomes available to the browser.',
    );
  }

  bool _selectVoice(_SpeechSynthesis synthesis) {
    final voices = synthesis.getVoices().toDart.where(
      (voice) =>
          voice.lang.toLowerCase().replaceAll('_', '-').split('-').first ==
          'pl',
    );
    if (voices.isEmpty) return false;
    _voice = voices.firstWhere(
      (voice) => voice.localService,
      orElse: () => voices.first,
    );
    return true;
  }

  Future<bool> initialize() async {
    final pending = _voiceLoading;
    if (pending != null) return pending.future;
    final synthesis = _synthesis;
    if (synthesis == null) {
      _warn('[Tuptu speech] This browser does not expose speechSynthesis.');
      return false;
    }
    if (_selectVoice(synthesis)) return true;
    // Chromium can populate voices asynchronously after the first getVoices.
    final loaded = Completer<bool>();
    _voiceLoading = loaded;
    final listener = ((JSAny? event) {
      if (!loaded.isCompleted && _selectVoice(synthesis)) loaded.complete(true);
    }).toJS;
    synthesis.addEventListener('voiceschanged', listener);
    try {
      if (_selectVoice(synthesis)) return true;
      _voiceTimeout = Timer(const Duration(seconds: 2), () {
        if (loaded.isCompleted) return;
        final ready = _selectVoice(synthesis);
        if (!ready) _reportUnavailable(synthesis);
        loaded.complete(ready);
      });
      return await loaded.future;
    } finally {
      _voiceTimeout?.cancel();
      _voiceTimeout = null;
      _voiceLoading = null;
      synthesis.removeEventListener('voiceschanged', listener);
    }
  }

  /// Play a short teaching excerpt even when no Polish voice is available.
  Future<void> playCue(String sound) async {
    stop();
    final training = TrainingCue.bundled[sound];
    if (training == null) return;
    final request = _cueRequest;
    final source = await rootBundle.load(training.asset);
    if (request != _cueRequest) return;
    final wav = training.browserWav(source);
    final playback = Completer<void>();
    final cue = _CueAudio('data:audio/wav;base64,${base64Encode(wav)}')
      ..volume = training.volume;
    _cue = cue;
    _cuePlayback = playback;
    cue.onended = ((JSAny? event) => _finishCue()).toJS;
    cue.onerror = ((JSAny? event) {
      _finishCue(StateError('Browser $sound cue failed.'));
    }).toJS;
    _cueTimeout = Timer(Duration(milliseconds: training.durationMs + 5000), () {
      _finishCue(StateError('Browser $sound cue timed out.'));
    });
    final finished = playback.future;
    unawaited(
      cue.play().toDart.catchError((Object error) {
        if (identical(_cue, cue)) _finishCue(error);
        return null;
      }),
    );
    await finished;
  }

  void _finishCue([Object? error]) {
    _cueTimeout?.cancel();
    _cueTimeout = null;
    _cue?.onended = null;
    _cue?.onerror = null;
    _cue?.pause();
    _cue = null;
    final playback = _cuePlayback;
    _cuePlayback = null;
    if (playback == null || playback.isCompleted) return;
    if (error == null) {
      playback.complete();
    } else {
      playback.completeError(error);
    }
  }

  Future<void> narrate(String text) {
    stop();
    final synthesis = _synthesis;
    final voice = _voice;
    if (text.trim().isEmpty) return Future<void>.value();
    if (synthesis == null || voice == null) {
      return Future<void>.error(
        StateError('No browser Polish voice is ready.'),
      );
    }
    final playback = Completer<void>();
    final utterance = _Utterance(text)
      ..lang = voice.lang
      ..voice = voice
      ..rate = 0.9;
    _playback = playback;
    _utterance = utterance;
    utterance.onstart = ((JSAny? event) {
      _timeout?.cancel();
      _timeout = Timer(const Duration(seconds: 90), () {
        _finish(StateError('Browser narration timed out.'));
        synthesis.cancel();
      });
    }).toJS;
    utterance.onend = ((JSAny? event) => _finish()).toJS;
    utterance.onerror = ((JSAny? event) {
      final code = event == null
          ? 'unknown'
          : _SpeechError(event as JSObject).error;
      _finish(
        StateError(
          'Browser narration failed: $code. Tap retry to enable speech.',
        ),
      );
    }).toJS;
    // Some browsers silently block speech until a user gesture. Do not leave
    // replay stuck in a speaking state when no completion event arrives.
    _timeout = Timer(const Duration(seconds: 5), () {
      _finish(StateError('Browser narration did not start. Tap retry.'));
      synthesis.cancel();
    });
    try {
      synthesis.speak(utterance);
    } catch (error) {
      _finish(error);
    }
    return playback.future;
  }

  void _finish([Object? error]) {
    if (error != null) _warn('[Tuptu speech] $error');
    _timeout?.cancel();
    _timeout = null;
    _utterance?.onstart = null;
    _utterance?.onend = null;
    _utterance?.onerror = null;
    _utterance = null;
    final playback = _playback;
    _playback = null;
    if (playback == null || playback.isCompleted) return;
    if (error == null) {
      playback.complete();
    } else {
      playback.completeError(error);
    }
  }

  void stop() {
    ++_cueRequest;
    _finishCue();
    _voiceTimeout?.cancel();
    final loading = _voiceLoading;
    if (loading != null && !loading.isCompleted) loading.complete(false);
    final wasPlaying = _playback != null;
    _finish();
    if (wasPlaying) _synthesis?.cancel();
  }
}
