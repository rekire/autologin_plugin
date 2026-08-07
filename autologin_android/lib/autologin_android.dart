/// The Android implementation of [AutologinPlatform].
library;

import 'package:autologin_platform_interface/autologin_platform_interface.dart';

/// The Android implementation of [AutologinPlatform].
class AutologinAndroid extends MethodChannelAutologin {
  /// Creates a new instance of [AutologinAndroid].
  AutologinAndroid();

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinAndroid();
  }
}
