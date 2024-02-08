import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [AutologinPlatform].
class AutologinAndroid extends AutologinPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('autologin_android');

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinAndroid();
  }

  @override
  Future<Compatibilities> performCompatibilityChecks() async {
    final json = await methodChannel.invokeMethod<String>('performCompatibilityChecks');
    if (json == null) {
      return const Compatibilities();
    }
    return Compatibilities.fromJson(json) ?? const Compatibilities();
  }

  @override
  Future<Credential?> requestCredentials() async {
    final json = await methodChannel.invokeMethod<String>('requestCredentials');
    if (json == null) {
      return null;
    }
    return Credential.fromJson(json);
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    return await methodChannel.invokeMethod<String>('saveCredentials', credential.toJson()) == 'true';
  }
}
