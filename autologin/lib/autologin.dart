import 'package:autologin_platform_interface/autologin_platform_interface.dart';
export 'package:autologin_platform_interface/autologin_platform_interface.dart' show Compatibilities, Credential;

/// The public interface of the AutologinPlugin. For a quick synchronous check you can check [isPlatformSupported].
/// When you need a full report of the [Compatibilities] you can [performCompatibilityChecks]. You can check the
/// [Compatibilities] class for the details. With [requestCredentials] your saved [Credential]s can be requested which
/// you need to safe before with [saveCredentials].
class AutologinPlugin {
  /// Returns `true` when the current platform is supported.
  static Future<bool> get isPlatformSupported => AutologinPlatform.instance.isPlatformSupported;

  /// Return the [Compatibilities] which depends on the platform or the browser in case of web
  static Future<Compatibilities> performCompatibilityChecks() =>
      AutologinPlatform.instance.performCompatibilityChecks();

  /// Returns the saved [Credential] when set by [saveCredentials] or is `null` when not found.
  static Future<Credential?> requestCredentials() async => AutologinPlatform.instance.requestCredentials();

  /// Returns `true` when the [Credential]s could be saved, otherwise `false`.
  static Future<bool> saveCredentials(Credential credential) async =>
      AutologinPlatform.instance.saveCredentials(credential);

  /// Returns the saved token which was set by [saveLoginToken] or is `null` when not found. This can be a refresh token
  /// or anything else which you can use to identify the user. You should validate that this token is still valid before
  /// authenticating the user. Depending on your use case asking for a second factor would be a good idea.
  static Future<String?> requestLoginToken() async => AutologinPlatform.instance.requestLoginToken();

  /// Returns `true` when the [token] could be saved, otherwise `false`.This token is intended to be synchronized by the
  /// platform you are using. This can be a refresh token or anything else which you can use to identify the user. For
  /// security reasons you should not store credentials.
  static Future<bool> saveLoginToken(String token) async => AutologinPlatform.instance.saveLoginToken(token);
}
