import 'dart:async';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:html';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'autologin_plugin.dart';

/// A web implementation of the AutologinPlugin plugin.
class AutologinPluginWeb {
  static late MethodChannel _channel;

  static void registerWith(Registrar registrar) {
    _channel = MethodChannel(
      'autologin_plugin',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = AutologinPluginWeb();
    _channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'isPlatformSupported':
        return html.window.navigator.credentials != null;
      case 'getLoginData':
        return await getLoginData();
      case 'saveLoginData':
        return await saveLoginData(call.arguments);
      case 'disableAutoLogIn':
        return await disableAutoLogIn();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'autologin_plugin for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  static Future<Credential?> getLoginData() async {
    final PasswordCredential? data =
        await html.window.navigator.credentials?.get({
      'password': true,
    });
    if (data == null) return null;
    return Credential(data.id!, data.password!);
  }

  static Future<bool> saveLoginData(Map<String, dynamic> data) async {
    await html.window.navigator.credentials?.store(PasswordCredential({
      'id': data['username'],
      'password': data['password'],
    }));
    return true;
  }

  static Future<bool> disableAutoLogIn() async {
    await html.window.navigator.credentials?.preventSilentAccess();
    return true;
  }
}
