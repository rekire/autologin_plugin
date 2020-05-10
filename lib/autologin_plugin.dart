import 'dart:async';

import 'package:flutter/services.dart';

class AutologinPlugin {
  static const MethodChannel _channel =
      const MethodChannel('autologin_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Credential> getLoginData() async {
    final List<dynamic> data = await _channel.invokeMethod('getLoginData');
    return Credential.fromArgs(data[0] as String, data[1] as String);
  }

  static Future<bool> saveLoginData(Credential credential) async {
    return await _channel.invokeMethod('saveLoginData', [credential.username, credential.password]);
  }
}

class Credential {
  String username;
  String password;

  Credential({this.username, this.password});

  Credential.fromArgs(String username, String password) {
    this.username = username;
    this.password = password;
  }
}
