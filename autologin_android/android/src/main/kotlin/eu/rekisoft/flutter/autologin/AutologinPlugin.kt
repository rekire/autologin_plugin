package eu.rekisoft.flutter.autologin

import android.util.Log
import androidx.activity.ComponentActivity
import androidx.credentials.*
import androidx.credentials.exceptions.*
import androidx.lifecycle.lifecycleScope
import com.google.android.gms.auth.blockstore.Blockstore
import com.google.android.gms.auth.blockstore.DeleteBytesRequest
import com.google.android.gms.auth.blockstore.RetrieveBytesRequest
import com.google.android.gms.auth.blockstore.RetrieveBytesResponse
import com.google.android.gms.auth.blockstore.StoreBytesData
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import eu.rekisoft.flutter.autologin.models.Compatibilities
import eu.rekisoft.flutter.autologin.models.Credential
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.launch
import kotlinx.coroutines.CoroutineScope
import java.io.PrintWriter
import java.io.StringWriter

/** AutologinPlugin */
class AutologinPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    val debugCalls = false

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var binding: ActivityPluginBinding? = null
    private val tasks: MutableList<(ActivityPluginBinding) -> Unit> = mutableListOf()

    private fun ActivityPluginBinding.launch(block: suspend CoroutineScope.() -> Unit) {
        if (activity !is ComponentActivity) {
            val actual = activity.javaClass.name
            val expected = ComponentActivity::class.java.name
            val link = "https://github.com/rekire/autologin_plugin?tab=readme-ov-file#android"
            throw ClassCastException("Your activity is from type $actual, but it should be $expected. See $link")
        }
        (activity as ComponentActivity).lifecycleScope.launch(block = block)
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "autologin_plugin")
        channel.setMethodCallHandler(this)

        debug("onAttachedToEngine")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        fun handleError(exception: Exception) {
            debug("Error processing...")
            val stackTrace = StringWriter()
            exception.printStackTrace(PrintWriter(stackTrace))
            result.error(exception::class.java.simpleName, exception.message, stackTrace.toString())
        }
        debug("Got call ${call.method}")
        when (call.method) {
            "performCompatibilityChecks" -> tasks.add { binding ->
                val hasPlayServices =
                    GoogleApiAvailability().isGooglePlayServicesAvailable(binding.activity) == ConnectionResult.SUCCESS
                result.success(Compatibilities(hasZeroTouchSupport = hasPlayServices).toMap())
            }

            "requestCredentials" -> binding?.launch {
                val credentialManager = CredentialManager.create(binding!!.activity)
                try {
                    val getCredRequest = GetCredentialRequest(listOf(GetPasswordOption()))

                    // Shows the user a dialog allowing them to pick a saved credential
                    val credential = credentialManager.getCredential(
                        context = binding!!.activity,
                        request = getCredRequest
                    ).credential as PasswordCredential
                    result.success(Credential(username = credential.id, password = credential.password).toMap())
                } catch (e: GetCredentialCancellationException) {
                    result.error("GetCredentialCancellationException", null, null)
                } catch (e: NoCredentialException) {
                    result.error("NoCredentialException", null, null)
                } catch (e: Exception) {
                    handleError(e)
                }
            }

            "saveCredentials" -> binding?.launch {
                val credentialManager = CredentialManager.create(binding!!.activity)
                val credentialMap = requireNotNull(call.arguments as? Map<*, *>)
                val id = requireNotNull(credentialMap["username"] as? String)
                val password = requireNotNull(credentialMap["password"] as? String)
                try {
                    credentialManager.createCredential(
                        context = binding!!.activity,
                        request = CreatePasswordRequest(id = id, password = password)
                    )
                    result.success(true.toString())
                } catch (e: CreateCredentialException) {
                    result.error("CreateCredentialException", e.message, e.errorMessage)
                } catch (e: Exception) {
                    handleError(e)
                }
            }

            "requestLoginToken" -> try {
                val client = Blockstore.getClient(binding!!.activity)

                val retrieveRequest = RetrieveBytesRequest.Builder()
                    .setKeys(listOf("login-token"))
                    .build()

                client.retrieveBytes(retrieveRequest)
                    .addOnSuccessListener { tokenResult: RetrieveBytesResponse ->
                        val tokenData = tokenResult.blockstoreDataMap["login-token"]
                        if (tokenData == null || tokenData.bytes.isEmpty()) {
                            result.success(null)
                        } else {
                            result.success(String(tokenData.bytes))
                        }
                    }
                    .addOnFailureListener { e: Exception ->
                        result.error(e.javaClass.simpleName, e.message, null)
                    }
            } catch (e: Exception) {
                result.error(e.javaClass.simpleName, e.message, null)
            }

            "saveLoginToken" -> try {
                val bytes = requireNotNull(call.arguments as? String).toByteArray()

                val client = Blockstore.getClient(binding!!.activity)

                val storeRequest = StoreBytesData.Builder()
                    .setBytes(bytes)
                    .setKey("login-token")
                    .setShouldBackupToCloud(true)
                    .build()
                client.storeBytes(storeRequest)
                    .addOnSuccessListener { storeResult: Int ->
                        result.success((storeResult == bytes.size).toString())
                    }
                    .addOnFailureListener { e ->
                        result.error(e.javaClass.simpleName, e.message, null)
                    }
            } catch (e: Exception) {
                result.error(e.javaClass.simpleName, e.message, null)
            }

            "deleteLoginToken" -> try {
                val client = Blockstore.getClient(binding!!.activity)

                val deleteRequest = DeleteBytesRequest.Builder().build()

                client.deleteBytes(deleteRequest)
                    .addOnSuccessListener {
                        result.success("true")
                    }
                    .addOnFailureListener { e ->
                        result.error(e.javaClass.simpleName, e.message, null)
                    }
            } catch (e: Exception) {
                result.error(e.javaClass.simpleName, e.message, null)
            }

            else -> result.notImplemented()
        }
        executeTasks()
    }

    private fun executeTasks() {
        binding?.let { binding ->
            tasks.forEach { task -> task.invoke(binding) }
            tasks.clear()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        debug("onReattachedToActivityForConfigChanges()")
        this.binding = binding
        executeTasks()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        debug("onAttachedToActivity()")
        this.binding = binding
        executeTasks()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        binding = null
    }

    private fun debug(msg: String) {
        if (debugCalls) Log.d("AutoLogin", msg)
    }
}
