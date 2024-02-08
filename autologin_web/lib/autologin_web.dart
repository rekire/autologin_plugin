import 'dart:html';
import 'dart:js';

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// The Web implementation of [AutologinPlatform].
class AutologinWeb extends AutologinPlatform {
  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith(Registrar? registrar) {
    AutologinPlatform.instance = AutologinWeb();
  }

  @override
  Future<Compatibilities> performCompatibilityChecks() async => Compatibilities(
        isPlatformSupported: window.navigator.credentials != null && context.hasProperty('PasswordCredential'),
      );

  @override
  Future<Credential?> requestCredentials() async {
    final data = await window.navigator.credentials?.get({
      'password': true,
    }) as PasswordCredential?;

    if (data == null) {
      return null;
    }

    return Credential(username: data.name, password: data.password);
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    await window.navigator.credentials?.store(
      PasswordCredential({
        'id': credential.username,
        'password': credential.password,
      }),
    );
    return true;
  }
}