package eu.rekisoft.flutter.autologin

import android.app.Activity.RESULT_OK
import android.content.Intent
import android.content.IntentSender
import android.util.Log
import com.google.android.gms.auth.api.credentials.Credential
import com.google.android.gms.auth.api.credentials.CredentialRequest
import com.google.android.gms.auth.api.credentials.Credentials
import com.google.android.gms.auth.api.credentials.CredentialsOptions
import com.google.android.gms.auth.api.credentials.IdentityProviders
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.ResolvableApiException
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

object LoginHelper {
    internal const val debugCalls = true

    fun hasPlayServices(binding: ActivityPluginBinding) =
        GoogleApiAvailability().isGooglePlayServicesAvailable(binding.activity) == ConnectionResult.SUCCESS

    private fun ActivityPluginBinding.addActivityResultListener(
        requestCodeFilter: Int,
        listener: (resultCode: Int, data: Intent?) -> Unit
    ) =
        addActivityResultListener(object : PluginRegistry.ActivityResultListener {
            override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
                if (requestCode == requestCodeFilter) {
                    listener(requestCode, data)
                    removeActivityResultListener(this)
                    return true
                }
                return false
            }
        })

    class GoogleApiError(val error: Int, cause: Exception? = null) :
        RuntimeException(
            "Error code $error while loading the login data (${cause?.message ?: "no details given"})",
            cause
        )
}

internal inline fun debug(msg: String) {
    if (LoginHelper.debugCalls) Log.d("AutoLogin", msg)
}
