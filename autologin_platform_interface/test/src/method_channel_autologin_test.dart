import 'package:autologin_platform_interface/src/compatibilities.dart';
import 'package:autologin_platform_interface/src/credential.dart';
import 'package:autologin_platform_interface/src/method_channel_autologin.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../autologin_platform_interface_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelAutologin', () {
    final mock = AutologinMock();
    late MethodChannelAutologin methodChannelAutologin;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelAutologin = MethodChannelAutologin();
      methodChannelAutologin.setup(); // just for code coverage
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        methodChannelAutologin.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'performCompatibilityChecks':
              return (await mock.performCompatibilityChecks()).toJson();
            case 'saveCredentials':
              final castedMap = methodCall.arguments as Map<Object?, Object?>;
              final map = castedMap.map((key, value) => MapEntry(key.toString(), value));
              return mock.saveCredentials(Credential.fromMap(map)!);
            case 'requestCredentials':
              return (await mock.requestCredentials())?.toJson();
            case 'requestLoginToken':
              return mock.requestLoginToken();
            case 'saveLoginToken':
              return mock.saveLoginToken(methodCall.arguments.toString());
            default:
              return null;
          }
        },
      );
    });

    tearDown(log.clear);

    test('performCompatibilityChecks works', () async {
      final result = await methodChannelAutologin.performCompatibilityChecks();
      expect(
        result,
        equals(
          const Compatibilities(
            isPlatformSupported: true,
            canSafeSecrets: true,
          ),
        ),
      );
    });

    test('requestCredentials returns correct values provided by saveCredentials', () async {
      expect(
        await methodChannelAutologin.requestCredentials(),
        equals(null),
      );
      const credential = Credential(username: 'foo', password: 'bar');
      expect(
        await methodChannelAutologin.saveCredentials(credential),
        equals(true),
      );
      expect(
        await methodChannelAutologin.requestCredentials(),
        equals(credential),
      );
    });

    test('requestLoginToken returns correct values provided by saveLoginToken', () async {
      expect(
        await methodChannelAutologin.requestLoginToken(),
        equals(null),
      );
      const token = 'foo-bar';
      expect(
        await methodChannelAutologin.saveLoginToken(token),
        equals(true),
      );
      expect(
        await methodChannelAutologin.requestLoginToken(),
        equals(token),
      );
    });
  });
}
