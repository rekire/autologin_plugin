/// The Windows implementation of [AutologinPlatform].
library;

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_windows/src/ffi.dart';

/// The Windows implementation of [AutologinPlatform].
class AutologinWindows extends AutologinPlatform {
  late String _appName;

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinWindows();
  }

  @override
  Future<Compatibilities> performCompatibilityChecks() async {
    return const Compatibilities(
      isPlatformSupported: true,
      canSafeSecrets: true,
    );
  }

  @override
  void setup({String? domain, String? appId, String? appName}) {
    _appName = appName!;
  }

  @override
  Future<Credential?> requestCredentials() async => credRead(_appName);

  @override
  Future<bool> saveCredentials(Credential credential) async {
    return credWrite(credential.username!, credential.password!, _appName);
  }

  @override
  Future<String?> requestLoginToken() async => null;

  @override
  Future<bool> saveLoginToken(String token) async => false;

  @override
  Future<bool> deleteLoginToken() async => false;
}
