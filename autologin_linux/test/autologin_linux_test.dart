import 'dart:convert';

import 'package:autologin_linux/autologin_linux.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinLinux', () {
    late AutologinLinux autologin;
    late List<MethodCall> log;
    const expectedCompatibilities = Compatibilities(isPlatformSupported: true);
    const expectedCredentials = Credential(username: 'foo', password: 'bar');
    const expectedToken = 'Example-Token';

    setUp(() async {
      autologin = AutologinLinux();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(autologin.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'performCompatibilityChecks':
            return jsonEncode(expectedCompatibilities.toJson());
          case 'requestCredentials':
            return jsonEncode(expectedCredentials.toJson());
          case 'saveCredentials':
            return 'true';
          case 'requestLoginToken':
          case 'saveLoginToken':
            throw Error();
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      AutologinLinux.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinLinux>());
    });

    test('performCompatibilityChecks returns expected value', () async {
      final report = await autologin.performCompatibilityChecks();
      expect(
        log,
        <Matcher>[isMethodCall('performCompatibilityChecks', arguments: null)],
      );
      expect(report, equals(expectedCompatibilities));
    });

    test('requestCredentials returns expected value', () async {
      final credentials = await autologin.requestCredentials();
      expect(
        log,
        <Matcher>[isMethodCall('requestCredentials', arguments: null)],
      );
      expect(credentials, equals(expectedCredentials));
    });

    test('saveCredentials returns expected value', () async {
      final report = await autologin.saveCredentials(expectedCredentials);
      expect(
        log,
        <Matcher>[isMethodCall('saveCredentials', arguments: expectedCredentials.toJson())],
      );
      expect(report, equals(true));
    });

    test('requestLoginToken returns nothing', () async {
      expect(log, <Matcher>[]);
      expect(() async => autologin.requestLoginToken(), throwsA(const TypeMatcher<PlatformException>()));
    });

    test('saveLoginToken returns expected value', () async {
      expect(log, <Matcher>[]);
      expect(() async => autologin.saveLoginToken(expectedToken), throwsA(const TypeMatcher<PlatformException>()));
    });
  });
}
