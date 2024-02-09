import 'package:autologin_ios/autologin_ios.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinIOS', () {
    const kPlatformName = 'iOS';
    late AutologinIOS autologin;
    late List<MethodCall> log;

    setUp(() async {
      autologin = AutologinIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(autologin.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      AutologinIOS.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await autologin.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
