/// The public interface of the AutologinPlugin.
library;

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
export 'package:autologin_platform_interface/autologin_platform_interface.dart'
    show Compatibilities, Credential;

/// The public interface of the AutologinPlugin. For a quick synchronous check
/// you can check [isPlatformSupported]. When you need a full report of the
/// [Compatibilities] you can [performCompatibilityChecks]. You can check the
/// [Compatibilities] class for the details. With [requestCredentials] your
/// saved [Credential]s can be requested which you need to safe before with
/// [saveCredentials].
class AutologinPlugin {
  /// Returns `true` when the current platform is supported.
  static Future<bool> get isPlatformSupported =>
      AutologinPlatform.instance.isPlatformSupported;

  /// Depending on your target platforms you need to setup attentional data. For
  /// iOS and MacOS the [domain] is required to ask the operating system for
  /// credentials for that domain. For Linux is an [appId] an [appName] required
  /// to select the credentials of your app (the name is in fact just for the
  /// label in the password manager). If you don't target those platforms you
  /// can omit this call.
  static void setup({String? domain, String? appId, String? appName}) =>
      AutologinPlatform.instance
          .setup(domain: domain, appId: appId, appName: appName);

  /// Return the [Compatibilities] which depends on the platform or the browser
  /// in case of web
  static Future<Compatibilities> performCompatibilityChecks() =>
      AutologinPlatform.instance.performCompatibilityChecks();

  /// Returns the saved [Credential] when set by [saveCredentials] or is `null`
  /// when not found.
  static Future<Credential?> requestCredentials() async =>
      AutologinPlatform.instance.requestCredentials();

  /// Returns `true` when the [Credential]s could be saved, otherwise `false`.
  static Future<bool> saveCredentials(Credential credential) async =>
      AutologinPlatform.instance.saveCredentials(credential);

  /// Returns the saved token which was set by [saveLoginToken] or is `null`
  /// when not found. This can be a refresh token or anything else which you can
  /// use to identify the user. You should validate that this token is still
  /// valid before authenticating the user. Depending on your use case asking
  /// for a second factor would be a good idea.
  static Future<String?> requestLoginToken() async =>
      AutologinPlatform.instance.requestLoginToken();

  /// Returns `true` when the [token] could be saved, otherwise `false`. This
  /// token is intended to be synchronized by the platform you are using. This
  /// can be a refresh token or anything else which you can use to identify the
  /// user. For security reasons you should not store credentials.
  static Future<bool> saveLoginToken(String token) async =>
      AutologinPlatform.instance.saveLoginToken(token);
}
