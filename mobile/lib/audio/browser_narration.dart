import 'dart:async';
import 'dart:js_interop';

@JS('window.speechSynthesis')
external _SpeechSynthesis? get _synthesis;

extension type _SpeechSynthesis(JSObject _) implements JSObject {
  external JSArray<_Voice> getVoices();
  external void addEventListener(String type, JSFunction listener);
  external void removeEventListener(String type, JSFunction listener);
  external void speak(_Utterance utterance);
  external void cancel();
}

extension type _Voice(JSObject _) implements JSObject {
  external String get lang;
  external bool get localService;
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

/// Browser-provided Polish narration; local voices are preferred, not required.
/// Remote voices may require connectivity. Teaching sound cues remain silent.
class BrowserNarration {
  _Voice? _voice;
  _Utterance? _utterance;
  Completer<void>? _playback;
  Timer? _timeout;
  Completer<bool>? _voiceLoading;
  Timer? _voiceTimeout;

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
    if (synthesis == null) return false;
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
        if (!loaded.isCompleted) loaded.complete(_selectVoice(synthesis));
      });
      return await loaded.future;
    } finally {
      _voiceTimeout?.cancel();
      _voiceTimeout = null;
      _voiceLoading = null;
      synthesis.removeEventListener('voiceschanged', listener);
    }
  }

  Future<void> narrate(String text) {
    stop();
    final synthesis = _synthesis;
    final voice = _voice;
    if (text.trim().isEmpty || synthesis == null || voice == null) {
      return Future<void>.value();
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
      _finish(
        StateError('Browser narration failed. Tap retry to enable speech.'),
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
    _voiceTimeout?.cancel();
    final loading = _voiceLoading;
    if (loading != null && !loading.isCompleted) loading.complete(false);
    final wasPlaying = _playback != null;
    _finish();
    if (wasPlaying) _synthesis?.cancel();
  }
}
