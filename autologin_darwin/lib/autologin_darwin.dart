/// The Darwin implementation of [AutologinPlatform] for iOS and MacOS.
library;

import 'package:autologin_platform_interface/autologin_platform_interface.dart';

/// The Darwin implementation of [AutologinPlatform] for iOS and MacOS.
class AutologinDarwin extends MethodChannelAutologin {
  late String _domain;

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinDarwin();
  }

  @override
  void setup({String? domain, String? appId, String? appName}) {
    _domain = domain!;
  }

  @override
  Future<Compatibilities> performCompatibilityChecks() async {
    return const Compatibilities(
      isPlatformSupported: true,
      canSafeSecrets: true,
      canEncryptSecrets: true,
      hasZeroTouchSupport: true,
    );
  }

  @override
  Future<Credential?> requestCredentials() async {
    final map = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'requestCredentials',
      _domain,
    );
    if (map == null) {
      return null;
    }
    return Credential.fromMap(
      map.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}
