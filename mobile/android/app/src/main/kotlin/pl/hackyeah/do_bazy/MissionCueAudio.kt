package pl.hackyeah.do_bazy

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.os.Handler
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

/** Quiet teaching excerpts and original, gently enveloped interaction tones. */
class MissionCueAudio(private val context: Context) {
    private data class Cue(val samples: ShortArray, val sampleRate: Int, val volume: Float)

    private var track: AudioTrack? = null
    private var playbackGeneration = 0

    fun play(name: String, handler: Handler, onComplete: () -> Unit) {
        stop()
        val (samples, sampleRate, volume) = createCue(name)
        val audio = AudioTrack.Builder()
            .setAudioAttributes(AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build())
            .setAudioFormat(AudioFormat.Builder().setSampleRate(sampleRate)
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setChannelMask(AudioFormat.CHANNEL_OUT_MONO).build())
            .setBufferSizeInBytes(samples.size * 2)
            .setTransferMode(AudioTrack.MODE_STATIC).build()
        track = audio
        require(audio.write(samples, 0, samples.size) == samples.size) { "Cue write failed" }
        audio.setVolume(volume)
        val token = playbackGeneration
        audio.play()
        handler.postDelayed({
            if (token == playbackGeneration) { stop(); onComplete() }
        }, samples.size * 1000L / sampleRate + 100)
    }

    private fun createCue(name: String): Cue {
        val tones = when (name) {
            "select" -> listOf(Tone(0, 150, 520.0))
            "action" -> listOf(Tone(0, 420, 620.0, 280.0))
            "success" -> listOf(Tone(0, 180, 523.25), Tone(150, 320, 659.25))
            "retry" -> listOf(Tone(0, 160, 392.0), Tone(200, 180, 392.0))
            else -> null
        }
        if (tones != null) return synthesize(tones)
        val (offset, duration) = when (name) {
            "alarm" -> 6000 to 4000
            "all_clear" -> 2000 to 3000
            "noise" -> 0 to 1000
            "busy" -> 0 to 2500
            else -> throw IllegalArgumentException("Unknown training cue")
        }
        val wav = context.assets.open("flutter_assets/assets/audio/mission01/$name.wav").use { it.readBytes() }
        val (samples, sampleRate) = decodeExcerpt(wav, offset, duration)
        return Cue(samples, sampleRate, when (name) { "noise" -> 0.7f; "busy" -> 0.4f; else -> 0.10f })
    }

    private data class Tone(
        val startMs: Int,
        val durationMs: Int,
        val frequency: Double,
        val endFrequency: Double = frequency,
    )

    /** Smooth starts and endings avoid clicks; no warning-like buzz or sharp attack. */
    private fun synthesize(tones: List<Tone>): Cue {
        val sampleRate = 22050
        val durationMs = tones.maxOf { it.startMs + it.durationMs }
        val mixed = DoubleArray(sampleRate * durationMs / 1000)
        tones.forEach { tone ->
            val start = sampleRate * tone.startMs / 1000
            val count = sampleRate * tone.durationMs / 1000
            val duration = tone.durationMs / 1000.0
            for (i in 0 until count) {
                val seconds = i.toDouble() / sampleRate
                val progress = i.toDouble() / (count - 1)
                val envelope = (1.0 - cos(2.0 * PI * progress)) / 2.0
                val phase = 2.0 * PI * (tone.frequency * seconds +
                    (tone.endFrequency - tone.frequency) * seconds * seconds / (2.0 * duration))
                mixed[start + i] += (sin(phase) + 0.12 * sin(2.0 * phase)) * envelope * 0.22
            }
        }
        val samples = ShortArray(mixed.size) { (mixed[it].coerceIn(-1.0, 1.0) * 32767).toInt().toShort() }
        return Cue(samples, sampleRate, 0.4f)
    }

    fun stop() {
        ++playbackGeneration
        val audio = track
        track = null
        runCatching { audio?.stop() }
        runCatching { audio?.release() }
    }

    private fun decodeExcerpt(wav: ByteArray, offsetMs: Int, durationMs: Int): Pair<ShortArray, Int> {
        val buffer = ByteBuffer.wrap(wav).order(ByteOrder.LITTLE_ENDIAN)
        require(wav.size >= 44 && String(wav, 0, 4, Charsets.US_ASCII) == "RIFF")
        require(String(wav, 8, 4, Charsets.US_ASCII) == "WAVE")
        var format = 0
        var rate = 0
        var bits = 0
        var dataStart = 0
        var dataLength = 0
        var chunk = 12
        while (chunk + 8 <= wav.size) {
            val id = String(wav, chunk, 4, Charsets.US_ASCII)
            val length = buffer.getInt(chunk + 4)
            require(length >= 0 && chunk + 8L + length <= wav.size)
            if (id == "fmt ") {
                require(length >= 16 && buffer.getShort(chunk + 10).toInt() == 1)
                format = buffer.getShort(chunk + 8).toInt()
                rate = buffer.getInt(chunk + 12)
                bits = buffer.getShort(chunk + 22).toInt()
            }
            if (id == "data") { dataStart = chunk + 8; dataLength = length; break }
            chunk += 8 + length + (length % 2)
        }
        require(rate > 0 && dataLength > 0)
        require((format == 6 && bits == 8) || (format == 1 && bits == 16))
        val bytesPerSample = bits / 8
        val first = rate * offsetMs / 1000
        val count = minOf(rate * durationMs / 1000, dataLength / bytesPerSample - first)
        require(count > 0)
        val samples = ShortArray(count) { i ->
            val at = dataStart + (first + i) * bytesPerSample
            if (format == 6) decodeALaw(wav[at].toInt() and 255) else buffer.getShort(at)
        }
        return samples to rate
    }

    // G.711 A-law decoding for the RCB's original 8 kHz mono recordings.
    private fun decodeALaw(encoded: Int): Short {
        val value = encoded xor 0x55
        val exponent = (value and 0x70) shr 4
        val mantissa = (value and 0x0f) shl 4
        val amplitude = if (exponent == 0) mantissa + 8 else (mantissa + 264) shl (exponent - 1)
        return (if (value and 0x80 != 0) amplitude else -amplitude).toShort()
    }
}
