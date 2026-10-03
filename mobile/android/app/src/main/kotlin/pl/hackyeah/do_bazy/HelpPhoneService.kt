package pl.hackyeah.do_bazy

import android.annotation.TargetApi
import android.content.Context
import android.os.Build
import android.telephony.NetworkRegistrationInfo
import android.telephony.PhoneStateListener
import android.telephony.ServiceState
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import io.flutter.plugin.common.EventChannel

/** Reports default-subscription voice service as a hint, never a call-connectivity guarantee. */
class HelpPhoneService(private val context: Context) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var unregisterListener: (() -> Unit)? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        dispose()
        eventSink = events
        events.success("unknown")
        try {
            val manager = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
                ?: return
            @Suppress("DEPRECATION")
            val voiceCapable = manager.isVoiceCapable
            if (!voiceCapable) {
                events.success("unavailable")
                return
            }
            val reportState: (ServiceState?) -> Unit = { state ->
                // A cancelled listener may still have a queued callback after a new subscription.
                if (eventSink === events) events.success(serviceStatus(state))
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                listenWithCallback(manager, reportState)
            } else {
                listenWithLegacyListener(manager, reportState)
            }
        } catch (_: RuntimeException) {
            // Unsupported devices, OEM restrictions and denied access remain unknown.
            eventSink = null
            stopListening()
            events.success("unknown")
        }
    }

    override fun onCancel(arguments: Any?) = dispose()

    fun dispose() {
        eventSink = null
        stopListening()
    }

    private fun stopListening() {
        val unregister = unregisterListener
        unregisterListener = null
        try {
            unregister?.invoke()
        } catch (_: RuntimeException) {
            // Cleanup must also work when the system telephony service is unavailable.
        }
    }

    @TargetApi(Build.VERSION_CODES.S)
    private fun listenWithCallback(manager: TelephonyManager, reportState: (ServiceState?) -> Unit) {
        val callback = object : TelephonyCallback(), TelephonyCallback.ServiceStateListener {
            override fun onServiceStateChanged(serviceState: ServiceState) = reportState(serviceState)
        }
        unregisterListener = { manager.unregisterTelephonyCallback(callback) }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            manager.registerTelephonyCallback(
                TelephonyManager.INCLUDE_LOCATION_DATA_NONE,
                context.mainExecutor,
                callback,
            )
        } else {
            manager.registerTelephonyCallback(context.mainExecutor, callback)
        }
    }

    @Suppress("DEPRECATION")
    private fun listenWithLegacyListener(manager: TelephonyManager, reportState: (ServiceState?) -> Unit) {
        val listener = object : PhoneStateListener() {
            override fun onServiceStateChanged(serviceState: ServiceState?) = reportState(serviceState)
        }
        unregisterListener = { manager.listen(listener, PhoneStateListener.LISTEN_NONE) }
        manager.listen(listener, PhoneStateListener.LISTEN_SERVICE_STATE)
    }

    private fun serviceStatus(state: ServiceState?): String = when (state?.state) {
        ServiceState.STATE_IN_SERVICE -> "available"
        ServiceState.STATE_EMERGENCY_ONLY -> "emergencyOnly"
        ServiceState.STATE_POWER_OFF -> "unavailable"
        ServiceState.STATE_OUT_OF_SERVICE ->
            if (hasEmergencyService(state)) "emergencyOnly" else "unavailable"
        else -> "unknown"
    }

    private fun hasEmergencyService(state: ServiceState): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return false
        // Android can report ordinary voice out of service while emergency service is offered.
        return state.networkRegistrationInfoList.any { registration ->
            NetworkRegistrationInfo.SERVICE_TYPE_EMERGENCY in registration.availableServices
        }
    }
}
