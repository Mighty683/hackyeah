package pl.hackyeah.do_bazy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var missionAudio: MissionAudio? = null
    private var audioChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        missionAudio = MissionAudio(this)
        audioChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "basebound/mission_audio")
        audioChannel?.setMethodCallHandler { call, result ->
            val audio = missionAudio
            if (audio == null) {
                result.error("AUDIO_UNAVAILABLE", "Audio engine is unavailable.", null)
                return@setMethodCallHandler
            }
            when (call.method) {
                "initialize" -> audio.initialize(result)
                "narrate" -> audio.narrate(call.argument<String>("text") ?: "", call.argument<String>("sound"), result)
                "stop" -> { audio.stop(); result.success(null) }
                "dispose" -> { audio.dispose(); result.success(null) }
                else -> result.notImplemented()
            }
        }
    }

    override fun onStop() {
        missionAudio?.stop()
        super.onStop()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        missionAudio?.dispose()
        missionAudio = null
        audioChannel?.setMethodCallHandler(null)
        audioChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
