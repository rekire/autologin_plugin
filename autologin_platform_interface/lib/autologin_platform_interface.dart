import 'package:autologin_platform_interface/src/compatibilities.dart';
import 'package:autologin_platform_interface/src/credential.dart';
import 'package:autologin_platform_interface/src/method_channel_autologin.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:autologin_platform_interface/src/compatibilities.dart'
    show Compatibilities;
export 'package:autologin_platform_interface/src/credential.dart'
    show Credential;
export 'package:autologin_platform_interface/src/method_channel_autologin.dart' show MethodChannelAutologin;

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
  static bool? _isPlatformSupported;

  /// The default instance of [AutologinPlatform] to use.
  ///
  /// Defaults to [MethodChannelAutologin].
  static AutologinPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [AutologinPlatform] when they register themselves.
  static set instance(AutologinPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the [Compatibilities] which depends on the platform or the browser in case of web
  Future<Compatibilities> performCompatibilityChecks();

  // Depending on your target platforms you need to setup attentional data. For iOS and MacOS the [domain] is required
  // to ask the operating system for credentials for that domain. For Linux is an [appId] an [appName] required to
  // select the credentials of your app (the name is in fact just for the label in the password manager). If you don't
  // target those platforms you can omit this call.
  void setup({String? domain, String? appId, String? appName});

  /// Returns `true` when the current platform is supported.
  Future<bool> get isPlatformSupported async {
    if (_isPlatformSupported == null) {
      final result = await _instance.performCompatibilityChecks();
      _isPlatformSupported = result.isPlatformSupported;
    }
    return _isPlatformSupported!;
  }

  /// Returns the saved [Credential] when set by [saveCredentials] or is `null` when not found.
  Future<Credential?> requestCredentials();

  /// Returns `true` when the [Credential]s could be saved, otherwise `false`.
  Future<bool> saveCredentials(Credential credential);

  /// Returns the saved token which was set by [saveLoginToken] or is `null` when not found. This can be a refresh token
  /// or anything else which you can use to identify the user. You should validate that this token is still valid before
  /// authenticating the user. Depending on your use case asking for a second factor would be a good idea.
  Future<String?> requestLoginToken();

  /// Returns `true` when the [token] could be saved, otherwise `false`. This token is intended to be synchronized by
  /// the platform you are using. This can be a refresh token or anything else which you can use to identify the user.
  /// For security reasons you should not store credentials.
  Future<bool> saveLoginToken(String token);
}
