import 'package:autologin_linux/autologin_linux.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinLinux', () {
    const kPlatformName = 'Linux';
    late AutologinLinux autologin;
    late List<MethodCall> log;

    setUp(() async {
      autologin = AutologinLinux();

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
      AutologinLinux.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinLinux>());
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
