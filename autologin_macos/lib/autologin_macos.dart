import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The MacOS implementation of [AutologinPlatform].
class AutologinMacOS extends AutologinPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('autologin_macos');

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinMacOS();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<Compatibilities> performCompatibilityChecks() {
    // TODO: implement performCompatibilityChecks
    throw UnimplementedError();
  }

  @override
  Future<Credential?> requestCredentials() {
    // TODO: implement requestCredentials
    throw UnimplementedError();
  }

  @override
  Future<bool> saveCredentials(Credential credential) {
    // TODO: implement saveCredentials
    throw UnimplementedError();
  }
}
