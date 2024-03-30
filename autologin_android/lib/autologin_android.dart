import 'package:autologin_platform_interface/autologin_platform_interface.dart';

/// The Android implementation of [AutologinPlatform].
class AutologinAndroid extends MethodChannelAutologin {
  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinAndroid();
  }
}
