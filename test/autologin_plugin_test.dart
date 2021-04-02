import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autologin_plugin/autologin_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('autologin_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return false;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('isPlatformSupported', () async {
    expect(await AutologinPlugin.isPlatformSupported, false);
  });
}
