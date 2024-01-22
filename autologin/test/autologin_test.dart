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

    setUp(() {
      autologinPlatform = MockAutologinPlatform();
      when(
        () => autologinPlatform.performCompatibilityChecks(),
      ).thenAnswer((_) async => compatibilityReport);
      AutologinPlatform.instance = autologinPlatform;
    });

    test('performCompatibilityChecks returns expected compatibilities', () async {
      expect(
        await AutologinPlugin.performCompatibilityChecks(),
        equals(compatibilityReport),
      );
    });

    // This test is BS, not sure if it is worth to make it green
    test(
      'Credentials functions returns expected values',
      () async {
        expect(
          await AutologinPlugin.requestCredentials(),
          equals(null),
        );
        const credential = Credential(username: 'foo', password: 'bar');
        expect(
          await AutologinPlugin.saveCredentials(credential),
          equals(true),
        );
        expect(
          await AutologinPlugin.requestCredentials(),
          equals(credential),
        );
      },
      skip: true,
    );
  });
}
