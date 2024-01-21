package eu.rekisoft.flutter.autologin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
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

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "autologin_android")
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
            "performCompatibilityChecks" -> result.success(
                """{"isPlatformSupported":true,
"canSafeSecrets":true,
"canEncryptSecrets":false,
"hasZeroTouchSupport":false,
"hasOneClickSupport":false}"""
            )

            "isPlatformSupported" ->
                tasks.add { binding ->
                    debug("isPlatformSupported()")
                    result.success(LoginHelper.isPlatformSupported(binding))
                }

            "requestCredentials" ->
                tasks.add { binding ->
                    debug("requestCredentials()")
                    LoginHelper.loadLoginData(binding, { username, password ->
                        result.success("""{"username":${username.quoted},"password":${password.quoted}}""")
                    }, ::handleError)
                }

            "saveLoginData" -> {
                operator fun MethodCall.get(arg: String): String = requireNotNull(argument(arg)) { "$arg was null" }
                tasks.add { binding ->
                    debug("saveLoginData()")
                    LoginHelper.saveLoginData(
                        binding,
                        call["username"],
                        call["password"],
                        { success ->
                            debug(if (success) "Login data were saved." else "Could not save login data"); result.success(
                            success
                        )
                        },
                        ::handleError
                    )
                }
            }

            "disableAutoLogIn" -> {
                tasks.add { binding ->
                    debug("disableAutoLogIn()")
                    LoginHelper.disableAutoLogIn(binding, result::success, ::handleError)
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

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
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
