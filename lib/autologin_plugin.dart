import 'dart:async';

import 'package:flutter/services.dart';

class AutologinPlugin {
  static const MethodChannel _channel = const MethodChannel('autologin_plugin');

  static Future<bool> get isPlatformSupported async {
    return await _channel.invokeMethod('isPlatformSupported');
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
    return await _channel.invokeMethod('disableAutoLogIn()');
  }
}

class Credential {
  String username;
  String password;

  Credential(this.username, this.password);
}
