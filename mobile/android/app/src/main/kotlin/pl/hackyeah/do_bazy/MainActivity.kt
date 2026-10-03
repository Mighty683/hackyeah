package pl.hackyeah.do_bazy

import android.app.AlertDialog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var missionAudio: MissionAudio? = null
    private var audioChannel: MethodChannel? = null
    private var helpPhoneChannel: MethodChannel? = null
    private var helpServiceChannel: EventChannel? = null
    private var helpPhoneService: HelpPhoneService? = null
    private var mockCallDialog: AlertDialog? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        helpPhoneService = HelpPhoneService(applicationContext)
        helpServiceChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "basebound/help_service")
        helpServiceChannel?.setStreamHandler(helpPhoneService)
        helpPhoneChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "basebound/help_phone")
        helpPhoneChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasServiceStateStream" -> result.success(true)
                "showMockEmergencyCall" -> {
                    if (mockCallDialog == null) {
                        mockCallDialog = AlertDialog.Builder(this)
                            .setTitle("112 · Demo call")
                            .setMessage("This is a pretend call for practice. No real call is made.")
                            .setPositiveButton("Close", null)
                            .create()
                        mockCallDialog?.setOnDismissListener { mockCallDialog = null }
                        mockCallDialog?.show()
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
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
        mockCallDialog?.dismiss()
        mockCallDialog = null
        helpPhoneChannel?.setMethodCallHandler(null)
        helpPhoneChannel = null
        helpServiceChannel?.setStreamHandler(null)
        helpServiceChannel = null
        helpPhoneService?.dispose()
        helpPhoneService = null
        missionAudio?.dispose()
        missionAudio = null
        audioChannel?.setMethodCallHandler(null)
        audioChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
