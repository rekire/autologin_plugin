import 'dart:async';

import 'package:autologin/autologin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DemoFrame());
}

/// This Frame is just to make sure that the DemoPage has a context which can show a snackbar
class DemoFrame extends StatelessWidget {
  const DemoFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Autologin-Plugin example app'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Align(
            child: SizedBox(
              width: 400,
              child: DemoPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

/// Most of those state fields are just for debugging what's going on
class _DemoPageState extends State<DemoPage> {
  bool? isPlatformSupported;
  bool obscurePassword = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String loginToken = 'Loading...';

  @override
  void initState() {
    super.initState();
    unawaited(initPlatformState());
    AutologinPlugin.setup(
      domain: 'rekire.github.io',
      appId: 'eu.rekisoft.flutter.autologin',
      appName: 'Autologin Demo',
    );
    AutologinPlugin.requestLoginToken().then((value) async {
      if (value != null) {
        setState(() => loginToken = value);
      } else {
        final hasZeroTouchSupport =
            (await AutologinPlugin.performCompatibilityChecks())
                .hasZeroTouchSupport;
        setState(
          () => loginToken = hasZeroTouchSupport
              ? 'null (this is the first app start or token was deleted)'
              : '(Platform not supported)',
        );
        if (hasZeroTouchSupport) {
          await AutologinPlugin.saveLoginToken('First start ${DateTime.now()}');
        }
      }
    }).onError((error, stackTrace) {
      setState(() => loginToken = error.toString());
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final isSupported = await AutologinPlugin.isPlatformSupported;
    setState(() => isPlatformSupported = isSupported);
  }

  Future<void> requestCredentials() async {
    final credentials = await AutologinPlugin.requestCredentials();

    if (mounted) {
      updateCredentials(credentials?.username, credentials?.password);
    }
  }

  Future<void> saveCredentials() async {
    final success = await AutologinPlugin.saveCredentials(
      Credential(
        username: usernameController.text,
        password: passwordController.text,
        domain: 'rekire.github.io',
      ),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save credentials!'),
        ),
      );
    }
  }

  void updateCredentials(String? username, String? password) {
    final usernameChanged = usernameController.text != username;
    final passwordChanged = passwordController.text != password;
    if (username == null || password == null) {
      final fields = [
        if (username == null) 'username',
        if (password == null) 'password',
      ].join(' or ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The API returned no $fields.')),
      );
    } else if (!usernameChanged || !passwordChanged) {
      final fields = [
        if (!usernameChanged) 'username',
        if (!passwordChanged) 'password',
      ].join(' and ');
      final verb = usernameChanged == passwordChanged ? 'have' : 'has';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The $fields $verb not changed.')),
      );
    }
    usernameController.text = username ?? '';
    passwordController.text = password ?? '';
  }

  @override
  Widget build(BuildContext context) {
    const target=kIsWeb ? 'browser' : 'platform';
    return Column(
      children: [
        if (isPlatformSupported != true)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '⚠️ This $target is not supported ⚠️',
            ),
          ),
        const Text('This app shows the features of the autologin flutter package. You cannot sign in this app, you need to implement that in your own app.'),
        const SizedBox(height: 16),
        TextFormField(
          controller: usernameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Username',
          ),
          onFieldSubmitted: (_) => saveCredentials(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.send,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => obscurePassword = !obscurePassword);
              },
              tooltip: obscurePassword ? 'Show password' : 'Hide password',
            ),
          ),
          onFieldSubmitted: (_) => saveCredentials(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: isPlatformSupported == true ? saveCredentials : null,
          child: const Text('Save credentials'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () =>
              updateCredentials('Some-Username', r'Example-P@§$w0rd!'),
          child: const Text('Enter sample data'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: isPlatformSupported == true ? requestCredentials : null,
          child: const Text('Request login data'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: isPlatformSupported == true
              ? () {
                  AutologinPlugin.deleteLoginToken();
                  setState(() => loginToken = '(token deleted)');
                }
              : null,
          child: const Text('Delete login token'),
        ),
        const SizedBox(height: 8),
        Text('Login-Token: $loginToken'),
      ],
    );
  }
}
