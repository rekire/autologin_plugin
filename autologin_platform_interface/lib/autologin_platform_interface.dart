import 'package:autologin_platform_interface/src/compatibilities.dart';
import 'package:autologin_platform_interface/src/credential.dart';
import 'package:autologin_platform_interface/src/method_channel_autologin.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:autologin_platform_interface/src/compatibilities.dart' show Compatibilities;
export 'package:autologin_platform_interface/src/credential.dart' show Credential;

/// The interface that implementations of autologin must implement.
///
/// Platform implementations should extend this class rather than implement it as `Autologin`.
/// Extending this class (using `extends`) ensures that the subclass will get the default implementation, while platform
/// implementations that `implements` this interface will be broken by newly added [AutologinPlatform] methods.
abstract class AutologinPlatform extends PlatformInterface {
  /// Constructs a AutologinPlatform.
  AutologinPlatform() : super(token: _token);

  static final Object _token = Object();

  static AutologinPlatform _instance = MethodChannelAutologin();
  static bool _isPlatformSupported = false;

  /// The default instance of [AutologinPlatform] to use.
  ///
  /// Defaults to [MethodChannelAutologin].
  static AutologinPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [AutologinPlatform] when they register themselves.
  static set instance(AutologinPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
    _instance.performCompatibilityChecks().then((result) => _isPlatformSupported = result.isPlatformSupported);
  }

  /// Return the [Compatibilities] which depends on the platform or the browser in case of web
  Future<Compatibilities> performCompatibilityChecks();

  /// Returns `true` when the current platform is supported.
  bool get isPlatformSupported => _isPlatformSupported;

  /// Returns the saved [Credential] when set by [saveCredentials] or is `null` when not found.
  Future<Credential?> requestCredentials();

  /// Returns `true` when the [Credential]s could be saved, otherwise `false`.
  Future<bool> saveCredentials(Credential credential);
}
