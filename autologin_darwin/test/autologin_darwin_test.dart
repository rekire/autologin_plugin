import 'package:autologin_darwin/autologin_darwin.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_test_utils/shared_tests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinDarwin', () {
    final autologin = AutologinDarwin();
    autologin.setup(domain: 'example-domain');
    final utils = SharedTests(
      compatibilities: const Compatibilities(
        isPlatformSupported: true,
        canSafeSecrets: true,
        canEncryptSecrets: true,
        hasZeroTouchSupport: true,
      ),
      methodChannel: autologin.methodChannel,
      platform: autologin,
    );

    setUp(utils.clearCallLog);

    test('can be registered', () {
      AutologinDarwin.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinDarwin>());
    });

    test(
      'performCompatibilityChecks returns expected value',
      () => utils.performCompatibilityChecksReturnsExpectedValue(
        usingMethodChannel: false,
      ),
    );

    test(
      'requestCredentials returns expected value',
      () => utils.requestCredentialsReturnsExpectedValue(
        platformArgs: 'example-domain',
      ),
    );

    test('saveLoginToken returns true', utils.saveLoginTokenReturnsTrue);

    test(
      'requestLoginToken returns expected value',
      utils.requestLoginTokenReturnsExpectedValue,
    );
  });
}
