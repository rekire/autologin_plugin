import 'package:autologin_linux/autologin_linux.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_test_utils/shared_tests.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinLinux', () {
    final autologin = AutologinLinux();
    final utils = SharedTests(
      compatibilities: const Compatibilities(
        isPlatformSupported: true,
        canSafeSecrets: true,
      ),
      methodChannel: autologin.methodChannel,
      platform: autologin,
    );

    setUp(utils.clearCallLog);

    test('can be registered', () {
      AutologinLinux.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinLinux>());
    });

    test(
      'performCompatibilityChecks returns expected value',
      utils.performCompatibilityChecksReturnsExpectedValue,
    );

    test(
      'requestCredentials returns expected value',
      () {
        autologin.setup(appId: 'demo.id', appName: 'Test app');
        utils.requestCredentialsReturnsExpectedValue(
          platformArgs: {'appId': 'demo.id', 'appName': 'Test app'},
        );
      },
    );

    test(
      'requestCredentials throws helpful errors',
      () async {
        const expectedMessage = 'For the Linux platform you need to call '
            "AutologinPlugin.setup(appId: 'your.app.id', appName: 'Your app "
            "name') before this call";

        // All arguments missing
        autologin.setup();
        expect(
          autologin.requestCredentials(),
          throwsA(
            predicate(
              (e) =>
                  e is PlatformException &&
                  e.message == expectedMessage &&
                  e.details ==
                      "The missing arguments are 'appId' and 'appName'.",
            ),
          ),
        );

        // app name missing
        autologin.setup(appId: 'demo.id');
        expect(
          autologin.requestCredentials(),
          throwsA(
            predicate(
              (e) =>
                  e is PlatformException &&
                  e.message == expectedMessage &&
                  e.details == "The missing argument is 'appName'.",
            ),
          ),
        );

        // app id missing
        autologin.setup(appName: 'test');
        expect(
          autologin.requestCredentials(),
          throwsA(
            predicate(
              (e) =>
                  e is PlatformException &&
                  e.message == expectedMessage &&
                  e.details == "The missing argument is 'appId'.",
            ),
          ),
        );
      },
    );

    test(
      'saveCredentials returns expected value',
      () async {
        autologin.setup(appId: 'demo.id', appName: 'Test app');
        final report =
            await autologin.saveCredentials(SharedTests.expectedCredentials);
        expect(report, equals(true));
        expect(utils.log, [
          isMethodCall(
            'saveCredentials',
            arguments: {
              ...SharedTests.expectedCredentials.toJson(),
              'appId': 'demo.id',
              'appName': 'Test app',
            },
          ),
        ]);
      },
    );

    test(
      'saveCredentials throws helpful errors',
      () async {
        const expectedMessage = 'For the Linux platform you need to call '
            "AutologinPlugin.setup(appId: 'your.app.id', appName: 'Your app "
            "name') before this call";

        // All arguments missing
        autologin.setup();
        expect(
          autologin.saveCredentials(SharedTests.expectedCredentials),
          throwsA(
            predicate(
              (e) =>
                  e is PlatformException &&
                  e.message == expectedMessage &&
                  e.details ==
                      "The missing arguments are 'appId' and 'appName'.",
            ),
          ),
        );

        // app name missing
        autologin.setup(appId: 'demo.id');
        expect(
          autologin.saveCredentials(SharedTests.expectedCredentials),
          throwsA(
            predicate(
              (e) =>
                  e is PlatformException &&
                  e.message == expectedMessage &&
                  e.details == "The missing argument is 'appName'.",
            ),
          ),
        );

        // app id missing
        autologin.setup(appName: 'test');
        expect(
          autologin.saveCredentials(SharedTests.expectedCredentials),
          throwsA(
            predicate(
              (e) =>
                  e is PlatformException &&
                  e.message == expectedMessage &&
                  e.details == "The missing argument is 'appId'.",
            ),
          ),
        );
      },
    );

    test('saveLoginToken returns false', utils.saveLoginTokenReturnsFalse);

    test('requestLoginToken returns nothing', () async {
      final token = await autologin.requestLoginToken();
      expect(
        utils.log,
        <Matcher>[isMethodCall('requestLoginToken', arguments: null)],
      );
      expect(token, equals(null));
    });
  });
}
