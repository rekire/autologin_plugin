package eu.rekisoft.flutter.autologin

import android.app.Activity.RESULT_OK
import android.content.Intent
import android.content.IntentSender
import com.google.android.gms.auth.api.credentials.Credential
import com.google.android.gms.auth.api.credentials.CredentialRequest
import com.google.android.gms.auth.api.credentials.Credentials
import com.google.android.gms.auth.api.credentials.CredentialsOptions
import com.google.android.gms.auth.api.credentials.IdentityProviders
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.ResolvableApiException
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

object LoginHelper {
    private const val loginRequestCode = 48232
    private const val saveRequestCode = 48233
    internal const val debugCalls = true

    fun isPlatformSupported(binding: ActivityPluginBinding) = GoogleApiAvailability().isGooglePlayServicesAvailable(binding.activity) == ConnectionResult.SUCCESS

    fun loadLoginData(binding: ActivityPluginBinding, callback: (username: String?, password: String?) -> Unit, error: (Exception?) -> Unit) {
        val availability = GoogleApiAvailability().isGooglePlayServicesAvailable(binding.activity)
        if (availability == ConnectionResult.SUCCESS) {
            val request = CredentialRequest.Builder()
                    .setAccountTypes(IdentityProviders.GOOGLE)
                    .setPasswordLoginSupported(true)
                    .build()
            Credentials.getClient(binding.activity).request(request).addOnCompleteListener {
                if (it.isSuccessful) {
                    val username = it.result?.credential?.id
                    val password = it.result?.credential?.password
                    callback(username, password)
                } else {
                    when (it.exception) {
                        is ResolvableApiException -> {
                            // This is most likely the case where the user has multiple saved
                            // credentials and needs to pick one. This requires showing UI to
                            // resolve the read request.
                            binding.addActivityResultListener(loginRequestCode) { _, data ->
                                debug("onActivityResult(_,_,$data)")
                                val credential = data?.getParcelableExtra<Credential>(Credential.EXTRA_KEY)
                                val username = credential?.id
                                val password = credential?.password
                                debug("username: $username, password: (${if (password.isNullOrBlank()) "not set" else "removed"})")
                                callback(username, password)
                            }
                            try {
                                (it.exception as ResolvableApiException).startResolutionForResult(binding.activity, loginRequestCode)
                            } catch (e: IntentSender.SendIntentException) {
                                //Log.e(TAG, "Failed to send resolution.", e)
                                error(e)
                            }
                        }
                        is ApiException ->
                            error(GoogleApiError((it.exception as ApiException).statusCode, it.exception))
                        else ->
                            error(it.exception)
                    }
                }
            }
        } else {
            error(GoogleApiError(availability))
        }
    }

    fun saveLoginData(binding: ActivityPluginBinding, email: String, password: String, success: () -> Unit, error: (Exception?) -> Unit) {
        val availability = GoogleApiAvailability().isGooglePlayServicesAvailable(binding.activity)
        if (availability == ConnectionResult.SUCCESS) {
            debug("Saving is possible")
            val credential: Credential = Credential.Builder(email)
                    .setPassword(password)
                    .build()
            val options = CredentialsOptions.Builder().forceEnableSaveDialog().build()
            Credentials.getClient(binding.activity, options).save(credential).addOnCompleteListener {
                if (it.isSuccessful) {
                    debug("Login data saved")
                    success()
                } else {
                    debug("Could not save it. $it.message")
                    if (it.exception is ResolvableApiException) {
                        // Try to resolve the save request. This will prompt the user if
                        // the credential is new.
                        debug("Adding listener for the save request")
                        binding.addActivityResultListener(saveRequestCode) { resultCode, _ ->
                            if (resultCode == RESULT_OK) {
                                success()
                            } else {
                                error(GoogleApiError(-1))
                            }
                        }
                        try {
                            (it.exception as ResolvableApiException).startResolutionForResult(binding.activity, saveRequestCode)
                            debug("Intend send to the system to ask to save the login data")
                        } catch (e: IntentSender.SendIntentException) {
                            debug("On no, something crashed. $e")
                            error(e)
                        }
                    } else {
                        debug("On no, something crashed.")
                        error(it.exception)
                    }
                }
            }
        } else {
            debug("Cannot save the login data")
            error(GoogleApiError(availability))
        }
    }

    fun disableAutoLogIn(binding: ActivityPluginBinding, success: (Boolean) -> Unit, error: (Exception?) -> Unit) {
        val available = GoogleApiAvailability().isGooglePlayServicesAvailable(binding.activity) == ConnectionResult.SUCCESS
        if (available) {
            Credentials.getClient(binding.activity).disableAutoSignIn()
        }
        success(available)
    }

    private fun ActivityPluginBinding.addActivityResultListener(requestCodeFilter: Int, listener: (resultCode: Int, data: Intent?) -> Unit) =
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
            RuntimeException("Error code $error while loading the login data (${cause?.message
                    ?: "no details given"})", cause)
}

internal inline fun debug(msg: String) = if (LoginHelper.debugCalls) println(msg) else Unit
