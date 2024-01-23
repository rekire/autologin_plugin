import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:autologin_web/autologin_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinWeb', () {
    late AutologinWeb autologin;
    const expectedCompatibilities = Compatibilities(isPlatformSupported: true);
    const expectedCredentials = Credential(username: 'foo', password: 'bar');

    setUp(() async {
      autologin = AutologinWeb();
    });

    test('can be registered', () {
      AutologinWeb.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinWeb>());
    });

    test('performCompatibilityChecks returns expected value', () async {
      final report = await autologin.performCompatibilityChecks();
      expect(report, equals(expectedCompatibilities));
    });

    test('requestCredentials returns expected value', () async {
      final credentials = await autologin.requestCredentials();
      expect(credentials, equals(expectedCredentials));
    });

    test('saveCredentials returns expected value', () async {
      final report = await autologin.saveCredentials(expectedCredentials);
      expect(report, equals(false)); // fail the test to validate that the CI executes it
    });
  });
}
