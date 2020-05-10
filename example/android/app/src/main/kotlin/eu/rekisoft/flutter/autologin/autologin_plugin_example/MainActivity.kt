package eu.rekisoft.flutter.autologin.autologin_plugin_example

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
    }
}
