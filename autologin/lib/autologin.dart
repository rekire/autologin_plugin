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
}
