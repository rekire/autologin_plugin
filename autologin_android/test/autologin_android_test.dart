import 'package:autologin_android/autologin_android.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_test_utils/shared_tests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinAndroid', () {
    final autologin = AutologinAndroid();
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
      AutologinAndroid.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinAndroid>());
    });

    test('performCompatibilityChecks returns expected value', utils.performCompatibilityChecksReturnsExpectedValue);

    test('requestCredentials returns expected value', utils.requestCredentialsReturnsExpectedValue);

    test('saveLoginToken returns expected value', utils.saveLoginTokenReturnsExpectedValue);

    test('requestLoginToken returns expected value', utils.requestLoginTokenReturnsExpectedValue);
  });
}
