/// The Web implementation of [AutologinPlatform].
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// Extension on [web.Credential] to access the password property
/// which is available on PasswordCredential instances.
extension PasswordCredentialExt on web.Credential {
  @JS('password')
  external String? get _password;

  String? get password => _password;
}

/// JS interop binding for creating a PasswordCredential.
/// The web package (1.1.x) does not expose a PasswordCredential constructor,
/// so we define our own.
@JS('PasswordCredential')
extension type PasswordCredential._(JSObject _) implements web.Credential {
  external factory PasswordCredential(PasswordCredentialInit data);
}

/// Init object for PasswordCredential constructor.
extension type PasswordCredentialInit._(JSObject _) implements JSObject {
  external factory PasswordCredentialInit({
    required String id,
    required String password,
  });
}

/// The Web implementation of [AutologinPlatform].
class AutologinWeb extends AutologinPlatform {
  /// Registers this class as the default instance of [AutologinPlatform]
  static void registerWith(Registrar? registrar) {
    AutologinPlatform.instance = AutologinWeb();
  }

  @override
  Future<Compatibilities> performCompatibilityChecks() async {
    final hasCredentials = web.window.navigator.has('credentials');
    final hasPasswordCredential = web.window.has('PasswordCredential');
    final canSafeSecrets = hasCredentials && hasPasswordCredential;
    return Compatibilities(
      isPlatformSupported: canSafeSecrets,
      canSafeSecrets: canSafeSecrets,
    );
  }

  @override
  Future<Credential?> requestCredentials() async {
    final nav = web.window.navigator;
    if (!nav.has('credentials')) {
      throw UnsupportedError(
        'The Credential Management API is not supported in this browser.',
      );
    }

    try {
      final options = web.CredentialRequestOptions(password: true);
      final data = await nav.credentials.get(options).toDart;
      if (data == null) {
        return null;
      }

      final id = data.id;
      final password = data.password;
      if (id.isEmpty && (password == null || password.isEmpty)) {
        return null;
      }
      return Credential(username: id, password: password ?? '');
    } catch (e) {
      throw PlatformException(
        code: e.runtimeType.toString(),
        message: 'Failed to request credentials: $e',
      );
    }
  }

  @override
  void setup({String? domain, String? appId, String? appName}) {}

  @override
  Future<bool> saveCredentials(Credential credential) async {
    final nav = web.window.navigator;
    if (!nav.has('credentials') || !web.window.has('PasswordCredential')) {
      throw UnsupportedError(
        'The Credential Management API is not supported in this browser.',
      );
    }

    try {
      final credentials = PasswordCredential(
        PasswordCredentialInit(
          id: credential.username ?? '',
          password: credential.password ?? '',
        ),
      );
      await nav.credentials.store(credentials).toDart;
      return true;
    } catch (e) {
      throw PlatformException(
        code: e.runtimeType.toString(),
        message: 'Failed to save credentials: $e',
      );
    }
  }

  @override
  Future<String?> requestLoginToken() async {
    throw UnsupportedError('The web platform does not support login tokens');
  }

  @override
  Future<bool> saveLoginToken(String token) async => false;

  @override
  Future<bool> deleteLoginToken() async => false;
}
