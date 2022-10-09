import 'dart:async';

// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:html';
import 'dart:js';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the AutologinPlugin plugin.
class AutologinPlugin {
  static MethodChannel _channel;

  static void registerWith(Registrar registrar) {
    _channel = MethodChannel(
      'autologin_plugin',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = AutologinPlugin();
    _channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'isPlatformSupported':
        return html.window.navigator.credentials != null &&
            context.hasProperty("PasswordCredential");
      case 'getLoginData':
        return await getLoginData();
      case 'saveLoginData':
        return await saveLoginData(
          username: call.arguments['username'],
          password: call.arguments['password'],
        );
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

  static Future<List<dynamic>> getLoginData() async {
    PasswordCredential data = await html.window.navigator.credentials?.get({
      'password': true,
    });
    return [data?.id, data?.password];
  }

  static Future<bool> saveLoginData({
    @required username,
    @required password,
  }) async {
    await html.window.navigator.credentials?.store(PasswordCredential({
      'id': username,
      'password': password,
    }));
    return true;
  }

  static Future<bool> disableAutoLogIn() async {
    await html.window.navigator.credentials?.preventSilentAccess();
    return true;
  }
}
