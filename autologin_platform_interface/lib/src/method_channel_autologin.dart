import 'dart:convert';

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// An implementation of [AutologinPlatform] that uses method channels.
class MethodChannelAutologin extends AutologinPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('autologin_plugin');

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
    final result = await methodChannel.invokeMethod<String>('saveCredentials', jsonEncode(credential.toJson()));
    return result == 'true';
  }
}
