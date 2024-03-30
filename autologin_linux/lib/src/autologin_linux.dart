import 'package:autologin_platform_interface/autologin_platform_interface.dart';

/// The Linux implementation of [AutologinPlatform].
class AutologinLinux extends MethodChannelAutologin {
  late String _appId;
  late String _appName;

  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith() {
    AutologinPlatform.instance = AutologinLinux();
  }

  @override
  void setup({String? domain, String? appId, String? appName}) {
    _appId = appId!;
    _appName = appName!;
  }

  @override
  Future<Credential?> requestCredentials({String? domain}) async {
    final json = await methodChannel.invokeMethod<Map<String, dynamic>>(
      'requestCredentials',
      {'appId': _appId, 'appName': _appName},
    );
    if (json == null) {
      return null;
    }
    return Credential.fromMap(json);
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    return await methodChannel.invokeMethod<String>(
          'saveCredentials',
          {
            ...credential.toJson(),
            'appId': _appId,
            'appName': _appName,
          },
        ) ==
        'true';
  }
}
