import 'dart:convert';

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Darwin implementation of [AutologinPlatform] for iOS and MacOS.
class AutologinDarwin extends AutologinPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('autologin_darwin');

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinDarwin();
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
  Future<Credential?> requestCredentials({String? domain}) async {
    final json = await methodChannel.invokeMethod<String>('requestCredentials', domain);
    if (json == null) {
      return null;
    }
    return Credential.fromJson(json);
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    return await methodChannel.invokeMethod<String>('saveCredentials', jsonEncode(credential.toJson())) == 'true';
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
