import 'dart:convert';

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
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        methodChannelAutologin.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'performCompatibilityChecks':
              return jsonEncode((await mock.performCompatibilityChecks()).toJson());
            case 'saveCredentials':
              return (await mock.saveCredentials(Credential.fromJson(methodCall.arguments.toString())!)).toString();
            case 'requestCredentials':
              final json = (await mock.requestCredentials())?.toJson();
              if (json != null) {
                return jsonEncode(json);
              } else {
                return null;
              }
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
  });
}
