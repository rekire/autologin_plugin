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
    private var onBound: ((ActivityPluginBinding) -> Unit)? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "autologin_plugin")
        channel.setMethodCallHandler(this)

        //flutterPluginBinding.flutterEngine.add
        println("onAttachedToEngine")
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "autologin_plugin")
            println("registerWith " + registrar.activity().javaClass.simpleName)
            channel.setMethodCallHandler(AutologinPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        fun handleError(exception: Exception?) {
            val stackTrace = StringWriter()
            exception?.printStackTrace(PrintWriter(stackTrace))
            if (exception is LoginHelper.GoogleApiError) {
                result.error(exception.error.toString(), exception.message, stackTrace.toString())
            } else {
                result.error("-2", exception?.message
                        ?: "No error details given", stackTrace.toString())
            }
        }
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "getLoginData" -> {
                onBound = { binding ->
                    println("loadLoginData()")
                    LoginHelper.loadLoginData(binding, { username, password ->
                        result.success(listOf(username, password))
                    }, ::handleError)
                    onBound = null
                }
                binding?.let {
                    onBound?.invoke(it)
                    onBound = null
                }
            }
            "saveLoginData" -> {
                operator fun MethodCall.get(arg: String): String = requireNotNull(argument(arg)) { "$arg was null" }
                onBound = { binding ->
                    println("saveLoginData()")
                    LoginHelper.saveLoginData(binding, call["username"], call["password"], { result.success(true) }, ::handleError)
                    onBound = null
                }
                binding?.let {
                    onBound?.invoke(it)
                    onBound = null
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        binding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        println("onReattachedToActivityForConfigChanges()")
        onBound?.invoke(binding)
        this.binding = binding
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        println("onAttachedToActivity()")
        onBound?.invoke(binding)
        this.binding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        binding = null
    }
}
