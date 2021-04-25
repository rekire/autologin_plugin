import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'autologin_plugin.dart';

/// A web implementation of the AutologinPlugin plugin.
class AutologinPluginWeb {
  static MethodChannel _channel;

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
        return false;
        break;
      case 'getLoginData':
      case 'saveLoginData':
      case 'disableAutoLogIn':
        // TODO handle that call, however the isPlatformSupported method says it is not supported yet ;-)
        html.window.alert('TODO: Handle the ${call.method}() call');
        return false;
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'autologin_plugin for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  static Future<Credential> getLoginData() async {
    final List<dynamic> data = await _channel.invokeMethod('getLoginData');
    if(data[0] == null) return null;
    return Credential(data[0] as String, data[1] as String);
  }

  static Future<bool> saveLoginData(Credential credential) async {
    return await _channel.invokeMethod('saveLoginData', <String, dynamic>{'username': credential.username, 'password': credential.password});
  }

  static Future<bool> disableAutoLogIn() async {
    return await _channel.invokeMethod('disableAutoLogIn');
  }
}
