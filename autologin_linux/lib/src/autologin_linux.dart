import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Linux implementation of [AutologinPlatform].
class AutologinLinux extends AutologinPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('autologin_linux');

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinLinux();
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
  Future<Credential?> requestCredentials({String? domain}) async {
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

  @override
  Future<String?> requestLoginToken() async {
    return methodChannel.invokeMethod<String>('requestLoginToken');
  }

  @override
  Future<bool> saveLoginToken(String token) async {
    return await methodChannel.invokeMethod<String>('saveLoginToken', token) == 'true';
  }
}
