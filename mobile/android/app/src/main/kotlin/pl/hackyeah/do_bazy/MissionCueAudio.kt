package pl.hackyeah.do_bazy

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.os.Handler
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** Plays short, quiet excerpts; the official source WAV files remain unchanged. */
class MissionCueAudio(private val context: Context) {
    private var track: AudioTrack? = null
    private var playbackGeneration = 0

    fun play(name: String, handler: Handler, onComplete: () -> Unit) {
        stop()
        val (offset, duration) = when (name) {
            "alarm" -> 6000 to 4000
            "all_clear" -> 2000 to 3000
            "noise" -> 0 to 1000
            else -> throw IllegalArgumentException("Unknown training cue")
        }
        val wav = context.assets.open("flutter_assets/assets/audio/mission01/$name.wav").use { it.readBytes() }
        val (samples, sampleRate) = decodeExcerpt(wav, offset, duration)
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
        audio.setVolume(if (name == "noise") 0.7f else 0.10f)
        val token = playbackGeneration
        audio.play()
        handler.postDelayed({
            if (token == playbackGeneration) { stop(); onComplete() }
        }, samples.size * 1000L / sampleRate + 100)
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
