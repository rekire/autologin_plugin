import 'dart:convert';

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/foundation.dart' show protected, visibleForTesting;
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// An implementation of [AutologinPlatform] that uses method channels.
class MethodChannelAutologin extends AutologinPlatform {
  /// The method channel used to interact with the native platform.
  @protected
  @visibleForTesting
  final methodChannel = const MethodChannel('autologin_plugin');

  @override
  Future<Compatibilities> performCompatibilityChecks() async {
    final map = await methodChannel.invokeMethod<Map<Object?, Object?>>('performCompatibilityChecks');
    if (map == null) {
      return const Compatibilities();
    }
    return Compatibilities.fromMap(map.map((key, value) => MapEntry(key.toString(), value))) ?? const Compatibilities();
  }

  @override
  void setup({String? domain, String? appId, String? appName}) {}

  @override
  Future<Credential?> requestCredentials({String? domain}) async {
    final map = await methodChannel.invokeMethod<Map<Object?, Object?>>('requestCredentials');
    if (map == null) {
      return null;
    }
    return Credential.fromMap(map.map((key, value) => MapEntry(key.toString(), value)));
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    return await methodChannel.invokeMethod<bool>('saveCredentials', credential.toJson()) == true;
  }

  @override
  Future<String?> requestLoginToken() async {
    return methodChannel.invokeMethod<String>('requestLoginToken');
  }

  @override
  Future<bool> saveLoginToken(String token) async {
    return await methodChannel.invokeMethod<bool>('saveLoginToken', token) == true;
  }
}
