import 'dart:convert';

import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_platform_interface/src/compatibilities.dart';
import 'package:autologin_platform_interface/src/credential.dart';
import 'package:flutter_test/flutter_test.dart';

class AutologinMock extends AutologinPlatform {
  String? credential;

  @override
  Future<Compatibilities> performCompatibilityChecks() async {
    return const Compatibilities(
      isPlatformSupported: true,
      canSafeSecrets: true,
    );
  }

  @override
  Future<Credential?> requestCredentials() async {
    if (credential == null) {
      return null;
    }
    return Credential.fromJson(credential);
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    this.credential = jsonEncode(credential.toJson());
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AutologinPlatformInterface', () {
    late AutologinPlatform autologinPlatform;

    setUp(() {
      autologinPlatform = AutologinMock();
      AutologinPlatform.instance = autologinPlatform;
    });

    test('performCompatibilityChecks works', () async {
      expect(
        await AutologinPlatform.instance.performCompatibilityChecks(),
        equals(
          const Compatibilities(
            isPlatformSupported: true,
            canSafeSecrets: true,
          ),
        ),
      );
    });

    test('requestCredentials returns correct values', () async {
      expect(
        await AutologinPlatform.instance.requestCredentials(),
        equals(null),
      );
      const credential = Credential(username: 'foo', password: 'bar');
      expect(
        await AutologinPlatform.instance.saveCredentials(credential),
        equals(true),
      );
      expect(
        await AutologinPlatform.instance.requestCredentials(),
        equals(credential),
      );
    });
  });
}
