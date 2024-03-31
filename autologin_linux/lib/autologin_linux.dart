import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/services.dart';

/// The Linux implementation of [AutologinPlatform].
class AutologinLinux extends MethodChannelAutologin {
  String? _appId;
  String? _appName;

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinLinux();
  }

  @override
  void setup({String? domain, String? appId, String? appName}) {
    _appId = appId;
    _appName = appName;
  }

  @override
  Future<Credential?> requestCredentials() async {
    _validateArguments();
    final json = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'requestCredentials',
      {'appId': _appId, 'appName': _appName},
    );
    if (json == null) {
      return null;
    }
    return Credential.fromMap(json.map((key, value) => MapEntry(key.toString(), value)));
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    _validateArguments();
    return await methodChannel.invokeMethod<bool>(
          'saveCredentials',
          {
            ...credential.toJson(),
            'appId': _appId,
            'appName': _appName,
          },
        ) ==
        true;
  }

  void _validateArguments() {
    final missingArgs = <String>[];
    if (_appId == null) {
      missingArgs.add("'appId'");
    }
    if (_appName == null) {
      missingArgs.add("'appName'");
    }
    if (missingArgs.isNotEmpty) {
      const expectedCall = "AutologinPlugin.setup(appId: 'your.app.id', appName: 'Your app name')";
      throw PlatformException(
        code: 'MissingArgument',
        message: 'For the Linux platform you need to call $expectedCall before this call',
        details: 'The missing argument${missingArgs.length > 1 ? 's are' : ' is'} ${missingArgs.join(' and ')}.',
      );
    }
  }
}
