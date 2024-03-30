import 'package:autologin_platform_interface/autologin_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class SharedTests {
  final Compatibilities expectedCompatibilities;
  final MethodChannel methodChannel;
  final AutologinPlatform platform;
  static const expectedCredentials = Credential(username: 'foo', password: 'bar');
  static const expectedToken = 'Example-Token';
  final log = <MethodCall>[];

  SharedTests({required Compatibilities compatibilities, required this.methodChannel, required this.platform})
      : expectedCompatibilities = compatibilities {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(methodChannel,
        (methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'performCompatibilityChecks':
          return expectedCompatibilities.toJson();
        case 'requestCredentials':
          return expectedCompatibilities.canSafeSecrets ? expectedCredentials.toJson() : null;
        case 'saveCredentials':
          return expectedCompatibilities.canSafeSecrets;
        case 'requestLoginToken':
          return expectedCompatibilities.hasZeroTouchSupport ? expectedToken : null;
        case 'saveLoginToken':
          return expectedCompatibilities.hasZeroTouchSupport;
        default:
          return null;
      }
    });
  }

  void clearCallLog() {
    print('clearCallLog $log');
    log.clear();
  }

  Future<void> performCompatibilityChecksReturnsExpectedValue() async {
    final report = await platform.performCompatibilityChecks();
    expect(log, [isMethodCall('performCompatibilityChecks', arguments: null)]);
    expect(report, equals(expectedCompatibilities));
  }

  Future<void> requestCredentialsReturnsExpectedValue() async {
    final credentials = await platform.requestCredentials();
    expect(log, [isMethodCall('requestCredentials', arguments: null)]);
    expect(credentials, equals(expectedCredentials));
  }

  Future<void> saveCredentialsReturnsExpectedValue() async {
    final report = await platform.saveCredentials(expectedCredentials);
    expect(report, equals(true));
    expect(log, [isMethodCall('saveCredentials', arguments: expectedCredentials.toJson())]);
  }

  Future<void> requestLoginTokenReturnsExpectedValue() async {
    final token = await platform.requestLoginToken();
    expect(log, <Matcher>[isMethodCall('requestLoginToken', arguments: null)]);
    expect(token, equals(expectedToken));
  }

  Future<void> saveLoginTokenReturnsExpectedValue() async {
    final report = await platform.saveLoginToken(expectedToken);
    expect(log, <Matcher>[isMethodCall('saveLoginToken', arguments: expectedToken)]);
    expect(report, equals(true));
  }

  Future<void> requestLoginTokenThrowsException() async {
    expect(() async => platform.requestLoginToken(), throwsA(const TypeMatcher<PlatformException>()));
    expect(log, <Matcher>[isMethodCall('saveLoginToken', arguments: null)]);
  }

  Future<void> saveLoginTokenThrowsException() async {
    expect(() async => platform.saveLoginToken(expectedToken), throwsA(const TypeMatcher<PlatformException>()));
    expect(log, <Matcher>[isMethodCall('saveLoginToken', arguments: expectedToken)]);
  }
}
