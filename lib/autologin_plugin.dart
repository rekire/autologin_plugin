import 'dart:async';

import 'package:flutter/services.dart';

class AutologinPlugin {
  static const MethodChannel _channel = const MethodChannel('autologin_plugin');

  static Future<bool> get isPlatformSupported async {
    try {
      return await _channel.invokeMethod('isPlatformSupported');
    } on MissingPluginException {
      return false;
    } catch (e) {
      print("Crash");
      print(e);
      throw e;
    }
  }

  static Future<Credential?> getLoginData() async {
    final List<dynamic> data = await _channel.invokeMethod('getLoginData');
    if (data[0] == null) return null;
    return Credential(data[0] as String?, data[1] as String?);
  }

  static Future<bool> saveLoginData(Credential credential) async =>
      await _channel.invokeMethod('saveLoginData', <String, dynamic>{
        'username': credential.username,
        'password': credential.password
      });

  static Future<bool> disableAutoLogIn() async =>
      await _channel.invokeMethod('disableAutoLogIn');
}

class Credential {
  String? username;
  String? password;

  Credential(this.username, this.password);
}
