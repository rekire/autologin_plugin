import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_test_utils/shared_tests.dart';
import 'package:autologin_windows/autologin_windows.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinDarwin', () {
    final autologin = AutologinWindows()..setup(appName: 'demo app');
    final utils = SharedTests(
      compatibilities: const Compatibilities(
        isPlatformSupported: true,
        canSafeSecrets: true,
      ),
      methodChannel: const MethodChannel('autologin_plugin'),
      platform: autologin,
    );

    setUp(utils.clearCallLog);

    test('can be registered', () {
      AutologinWindows.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinWindows>());
    });

    test(
      'performCompatibilityChecks returns expected value',
      () => utils.performCompatibilityChecksReturnsExpectedValue(
        usingMethodChannel: false,
      ),
    );

    test('requestCredentials returns expected value', () async {
      final result = await autologin.requestCredentials();
      // this ffi call is expected to fail in this test
      expect(result, equals(null));
    });

    test('saveLoginToken returns true', () async {
      final report = await autologin.saveCredentials(
        SharedTests.expectedCredentials,
      );
      expect(report, equals(true));
    });

    test(
      'requestLoginToken returns expected value',
      () async => expect(await autologin.requestLoginToken(), equals(null)),
    );
  });
}
