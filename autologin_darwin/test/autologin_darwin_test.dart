import 'dart:convert';

import 'package:autologin_darwin/autologin_darwin.dart';
import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutologinDarwin', () {
    late AutologinDarwin autologin;
    late List<MethodCall> log;
    const expectedCompatibilities = Compatibilities(
      isPlatformSupported: true,
      canSafeSecrets: true,
      canEncryptSecrets: true,
      hasZeroTouchSupport: true,
    );
    const expectedCredentials = Credential(username: 'foo', password: 'bar');
    const expectedToken = 'foo-bar';

    setUp(() async {
      autologin = AutologinDarwin();

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
            return expectedToken;
          case 'saveLoginToken':
            return 'true';
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      AutologinDarwin.registerWith();
      expect(AutologinPlatform.instance, isA<AutologinDarwin>());
    });

    test('performCompatibilityChecks returns expected value', () async {
      final report = await autologin.performCompatibilityChecks();
      //expect(
      //  log,
      //  <Matcher>[isMethodCall('performCompatibilityChecks', arguments: null)],
      //);
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

    // ignore_for_file: avoid_catching_errors
    test('saveCredentials is not implemented', () async {
      final report = await autologin.saveCredentials(expectedCredentials);
      expect(
        log,
        <Matcher>[isMethodCall('saveCredentials', arguments: jsonEncode(expectedCredentials.toJson()))],
      );
      expect(report, equals(true));
    });

    test('requestLoginToken returns expected value', () async {
      final token = await autologin.requestLoginToken();
      expect(
        log,
        <Matcher>[isMethodCall('requestLoginToken', arguments: null)],
      );
      expect(token, equals(expectedToken));
    });

    test('saveLoginToken returns expected value', () async {
      final report = await autologin.saveLoginToken(expectedToken);
      expect(
        log,
        <Matcher>[isMethodCall('saveLoginToken', arguments: expectedToken)],
      );
      expect(report, equals(true));
    });
  });
}
