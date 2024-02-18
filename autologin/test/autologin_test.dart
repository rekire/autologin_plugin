import 'package:autologin/autologin.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAutologinPlatform extends Mock with MockPlatformInterfaceMixin implements AutologinPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Autologin', () {
    late AutologinPlatform autologinPlatform;
    const compatibilityReport = Compatibilities();
    const sampleCredential = Credential(username: 'foo', password: 'bar');
    const sampleToken = 'login-token';

    setUpAll(() {
      registerFallbackValue(sampleCredential);
    });

    setUp(() {
      autologinPlatform = MockAutologinPlatform();
      Credential? cache;
      String? cachedToken;
      when(
        () => autologinPlatform.performCompatibilityChecks(),
      ).thenAnswer((_) async => compatibilityReport);
      when(
        () => autologinPlatform.isPlatformSupported,
      ).thenAnswer((_) async => true);
      when(
        () => autologinPlatform.requestCredentials(),
      ).thenAnswer((_) async => cache);
      when(
        () => autologinPlatform.saveCredentials(captureAny()),
      ).thenAnswer((answer) async {
        cache = answer.positionalArguments.first as Credential;
        return true;
      });
      when(
        () => autologinPlatform.requestLoginToken(),
      ).thenAnswer((answer) async => cachedToken);
      when(
        () => autologinPlatform.saveLoginToken(captureAny()),
      ).thenAnswer((answer) async {
        cachedToken = answer.positionalArguments.first as String;
        return true;
      });
      AutologinPlatform.instance = autologinPlatform;
    });

    test('performCompatibilityChecks returns expected compatibilities', () async {
      expect(
        await AutologinPlugin.performCompatibilityChecks(),
        equals(compatibilityReport),
      );
      expect(
        await AutologinPlugin.isPlatformSupported,
        equals(true),
      );
    });

    test(
      'Credentials functions returns expected values',
      () async {
        expect(
          await AutologinPlugin.requestCredentials(),
          equals(null),
        );
        expect(
          await AutologinPlugin.saveCredentials(sampleCredential),
          equals(true),
        );
        expect(
          await AutologinPlugin.requestCredentials(),
          equals(sampleCredential),
        );
      },
    );

    test(
      'LoginToken functions returns expected values',
      () async {
        expect(
          await AutologinPlugin.requestLoginToken(),
          equals(null),
        );
        expect(
          await AutologinPlugin.saveLoginToken(sampleToken),
          equals(true),
        );
        expect(
          await AutologinPlugin.requestLoginToken(),
          equals(sampleToken),
        );
      },
    );
  });
}
