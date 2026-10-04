package pl.hackyeah.do_bazy

import android.content.Context
import android.media.AudioAttributes
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/** Device-local Polish narration. Network voices are never selected. */
class MissionAudio(private val context: Context) {
    private val handler = Handler(Looper.getMainLooper())
    private val cues = MissionCueAudio(context)
    private var speech: TextToSpeech? = null
    private var ready = false
    private var generation = 0
    private var initializationGeneration = 0
    private val initializing = mutableListOf<MethodChannel.Result>()
    private var pending: MethodChannel.Result? = null

    fun initialize(result: MethodChannel.Result) {
        if (ready) { result.success(true); return }
        initializing.add(result)
        if (speech != null) return
        val token = ++initializationGeneration
        try {
            speech = TextToSpeech(context) { status ->
                handler.post { finishInitialization(token, status) }
            }
            handler.postDelayed({
                if (token == initializationGeneration && initializing.isNotEmpty()) {
                    failInitialization()
                }
            }, 8000)
        } catch (_: Exception) {
            failInitialization()
        }
    }

    private fun finishInitialization(token: Int, status: Int) {
        if (token != initializationGeneration || initializing.isEmpty()) return
        val engine = speech
        if (status != TextToSpeech.SUCCESS || engine == null) {
            failInitialization(); return
        }
        try {
            val voice = engine.voices.orEmpty().filter {
                it.locale.language == "pl" && !it.isNetworkConnectionRequired &&
                    !it.features.orEmpty().contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)
            }.sortedWith(compareByDescending<android.speech.tts.Voice> {
                it.locale == Locale.forLanguageTag("pl-PL")
            }.thenByDescending { it.quality }).firstOrNull()
            if (voice == null || engine.setVoice(voice) != TextToSpeech.SUCCESS) {
                Log.i("BaseboundMissionAudio", "No installed offline Polish voice is available")
                failInitialization(); return
            }
            engine.setSpeechRate(0.88f)
            engine.setAudioAttributes(AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build())
            engine.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) = Unit
                override fun onDone(utteranceId: String?) {
                    handler.post { completeNarration(utteranceId) }
                }
                override fun onStop(utteranceId: String?, interrupted: Boolean) {
                    handler.post { completeNarration(utteranceId, true) }
                }
                @Deprecated("Android compatibility callback")
                override fun onError(utteranceId: String?) {
                    handler.post { completeNarration(utteranceId, true) }
                }
                override fun onError(utteranceId: String?, errorCode: Int) {
                    handler.post { completeNarration(utteranceId, true) }
                }
            })
            ready = true
            Log.i("BaseboundMissionAudio", "Offline Polish narration initialized: ${voice.name}")
            val results = initializing.toList()
            initializing.clear()
            results.forEach { it.success(true) }
        } catch (_: Exception) {
            failInitialization()
        }
    }

    private fun failInitialization() {
        ++initializationGeneration
        ready = false
        runCatching { speech?.shutdown() }
        speech = null
        val results = initializing.toList()
        initializing.clear()
        results.forEach { it.success(false) }
    }

    fun narrate(text: String, sound: String?, result: MethodChannel.Result) {
        stop()
        // Short interaction cues remain available when no offline voice exists.
        if (text.isNotBlank() && (!ready || speech == null)) {
            result.error("AUDIO_UNAVAILABLE", "Zainstaluj polski głos offline z pomocą dorosłego.", null)
            return
        }
        pending = result
        val token = generation
        try {
            if (sound == null) speak(text, token)
            else cues.play(sound, handler) {
                if (token == generation) speak(text, token)
            }
        } catch (_: Exception) {
            failNarration("AUDIO_CUE", "Nie udało się odtworzyć dźwięku ćwiczenia.")
        }
    }

    private fun speak(text: String, token: Int) {
        if (token != generation || pending == null) return
        if (text.isBlank()) { completeNarration(token.toString()); return }
        val params = Bundle().apply { putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, 0.85f) }
        val status = runCatching {
            speech?.speak(text, TextToSpeech.QUEUE_FLUSH, params, token.toString())
        }.getOrNull()
        if (status != TextToSpeech.SUCCESS) {
            failNarration("AUDIO_SPEECH", "Nie udało się odtworzyć głosu offline.")
            return
        }
        // Some vendor engines omit progress callbacks after an error.
        handler.postDelayed({
            if (token == generation && pending != null) {
                failNarration("AUDIO_TIMEOUT", "Głos offline nie zakończył odtwarzania.")
            }
        }, maxOf(15000L, text.length * 150L))
    }

    private fun completeNarration(utteranceId: String?, failed: Boolean = false) {
        if (utteranceId != generation.toString()) return
        if (failed) { failNarration("AUDIO_SPEECH", "Głos offline zatrzymał się niespodziewanie."); return }
        val result = pending
        pending = null
        result?.success(null)
    }

    private fun failNarration(code: String, message: String) {
        val result = pending
        pending = null
        ++generation
        cues.stop()
        runCatching { speech?.stop() }
        result?.error(code, message, null)
    }

    fun stop() {
        ++generation
        cues.stop()
        runCatching { speech?.stop() }
        val result = pending
        pending = null
        result?.success(null)
    }

    fun dispose() {
        stop()
        handler.removeCallbacksAndMessages(null)
        failInitialization()
    }
}
