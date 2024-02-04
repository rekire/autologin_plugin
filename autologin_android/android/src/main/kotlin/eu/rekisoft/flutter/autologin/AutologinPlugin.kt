package eu.rekisoft.flutter.autologin

import androidx.annotation.NonNull
import androidx.credentials.*
import androidx.credentials.exceptions.*
import eu.rekisoft.flutter.autologin.models.Compatibilities
import eu.rekisoft.flutter.autologin.models.Credential
import eu.rekisoft.flutter.autologin.models.toJSON
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.runBlocking
import java.io.PrintWriter
import java.io.StringWriter

/** AutologinPlugin */
public class AutologinPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var binding: ActivityPluginBinding? = null
    private val tasks: MutableList<(ActivityPluginBinding) -> Unit> = mutableListOf()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "autologin_android")
        channel.setMethodCallHandler(this)

        debug("onAttachedToEngine")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        fun handleError(exception: Exception?) {
            debug("Error processing...")
            val stackTrace = StringWriter()
            exception?.printStackTrace(PrintWriter(stackTrace))
            if (exception is LoginHelper.GoogleApiError) {
                result.error(exception.error.toString(), exception.message, stackTrace.toString())
            } else {
                result.error(
                    "-2", exception?.message
                        ?: "No error details given", stackTrace.toString()
                )
            }
        }
        debug("Got call ${call.method}")
        when (call.method) {
            "performCompatibilityChecks" -> tasks.add { binding ->
                result.success(Compatibilities(isPlatformSupported = LoginHelper.isPlatformSupported(binding)).toJSON())
            }

            "requestCredentials" -> runBlocking {
                val credentialManager = CredentialManager.create(binding!!.activity)
                try {
                    val getCredRequest = GetCredentialRequest(listOf(GetPasswordOption()))

                    // Shows the user a dialog allowing them to pick a saved credential
                    val credential = credentialManager.getCredential(
                        context = binding!!.activity,
                        request = getCredRequest
                    ).credential as PasswordCredential
                    result.success(Credential(username = credential.id, password = credential.password).toJSON())
                } catch (e: GetCredentialCancellationException) {
                    result.error("GetCredentialCancellationException", null, null)
                } catch (e: NoCredentialException) {
                    result.error("NoCredentialException", null, null)
                } catch (e: Exception) {
                    handleError(e)
                }
            }

            "saveCredentials" -> runBlocking {
                val credentialManager = CredentialManager.create(binding!!.activity)
                val credentialMap = requireNotNull(call.arguments as? Map<String, String>)
                val id = requireNotNull(credentialMap["username"])
                val password = requireNotNull(credentialMap["password"])
                try {
                    val credentialResponse = credentialManager.createCredential(
                        context = binding!!.activity,
                        request = CreatePasswordRequest(id = id, password = password)
                    )
                    result.success((credentialResponse.data != null).toString())
                } catch (e: CreateCredentialCancellationException) {
                    result.error("CreateCredentialCancellationException", null, null)
                } catch (e: Exception) {
                    handleError(e)
                }
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

    // poor mans json encoding util. in other words replace me with gson or similar
    private val String?.quoted: String?
        get() = this?.let { """"${replace("\"", "\\\"")}"""" }

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
}
