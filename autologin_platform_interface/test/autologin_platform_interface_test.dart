import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class AutologinMock extends AutologinPlatform {
  Map<String, dynamic>? credential;
  String? loginToken;

  @override
  Future<Compatibilities> performCompatibilityChecks() async {
    return const Compatibilities(
      isPlatformSupported: true,
      canSafeSecrets: true,
    );
  }

  @override
  void setup({String? domain, String? appId, String? appName}) {}

  @override
  Future<Credential?> requestCredentials({String? domain}) async {
    if (credential == null) {
      return null;
    }
    return Credential.fromMap(credential);
  }

  @override
  Future<bool> saveCredentials(Credential credential) async {
    this.credential = credential.toJson();
    return true;
  }

  @override
  Future<String?> requestLoginToken() async {
    return loginToken;
  }

  @override
  Future<bool> saveLoginToken(String token) async {
    loginToken = token;
    return true;
  }

  @override
  Future<bool> deleteLoginToken() async {
    loginToken = null;
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

    test('isPlatformSupported returns true', () async {
      expect(
        await AutologinPlatform.instance.isPlatformSupported,
        equals(true),
      );
    });

    test('requestLoginToken returns correct values provided by saveLoginToken',
        () async {
      expect(
        await AutologinPlatform.instance.requestLoginToken(),
        equals(null),
      );
      const expectedToken = 'foo-bar';
      expect(
        await AutologinPlatform.instance.saveLoginToken(expectedToken),
        equals(true),
      );
      expect(
        await AutologinPlatform.instance.requestLoginToken(),
        equals(expectedToken),
      );
    });
  });
}
