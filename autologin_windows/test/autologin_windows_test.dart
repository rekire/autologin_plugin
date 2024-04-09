import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_test_utils/shared_tests.dart';
import 'package:autologin_windows/autologin_windows.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinDarwin', () {
    final autologin = AutologinWindows();
    final utils = SharedTests(
      compatibilities: const Compatibilities(
        isPlatformSupported: true,
        canSafeSecrets: true,
      ),
      methodChannel: const MethodChannel('autologin_plugin'),
      platform: autologin,
    );

    setUp(() => autologin.setup(appName: 'demo app'));

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
      await autologin.saveCredentials(SharedTests.expectedCredentials);
      final result = await autologin.requestCredentials();
      expect(result, equals(SharedTests.expectedCredentials));
    });

    test('verify that non existing accounts return null', () async {
      autologin.setup(appName: 'none existing app');
      expect(await autologin.requestCredentials(), equals(null));
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

    test(
      'verify that save token fails',
      () async => expect(
        await autologin.saveLoginToken(SharedTests.expectedToken),
        equals(false),
      ),
    );
  });
}
