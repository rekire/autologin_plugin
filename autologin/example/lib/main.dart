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
  String? usernameNote;
  String? passwordNote;
  bool obscurePassword = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String loginToken = 'Loading...';

  @override
  void initState() {
    super.initState();
    unawaited(initPlatformState());
    usernameController.addListener(resetUsernameNote);
    passwordController.addListener(resetPasswordNote);
    AutologinPlugin.requestLoginToken().then((value) async {
      if (value != null) {
        setState(() => loginToken = value);
      } else {
        final hasZeroTouchSupport = (await AutologinPlugin.performCompatibilityChecks()).hasZeroTouchSupport;
        setState(() => loginToken = hasZeroTouchSupport ? 'This is the first app start' : 'Platform not supported');
        if (hasZeroTouchSupport) {
          await AutologinPlugin.saveLoginToken('First start ${DateTime.now()}');
        }
      }
    }).onError((error, stackTrace) {
      setState(() => loginToken = error.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.removeListener(resetUsernameNote);
    passwordController.removeListener(resetPasswordNote);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final isSupported = await AutologinPlugin.isPlatformSupported;
    setState(() => isPlatformSupported = isSupported);
  }

  void resetUsernameNote() {
    setState(() => usernameNote = null);
  }

  void resetPasswordNote() {
    setState(() => passwordNote = null);
  }

  Future<void> requestCredentials() async {
    final credentials = await AutologinPlugin.requestCredentials(domain: 'rekire.github.io');

    if (mounted) {
      setState(() {
        if (credentials?.username != null) {
          usernameController.text = credentials!.username!;
          usernameNote = null;
        } else {
          usernameController.text = '';
          usernameNote = 'API did not provide a username';
        }
        if (credentials?.password != null) {
          passwordController.text = credentials!.password!;
          passwordNote = null;
        } else {
          passwordController.text = '';
          passwordNote = 'API did not provide a password';
        }
      });
    }
  }

  Future<void> saveCredentials() async {
    final success = await AutologinPlugin.saveCredentials(
      Credential(username: usernameController.text, password: passwordController.text, domain: 'rekire.github.io'),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save credentials!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isPlatformSupported != true)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('⚠️ This ${kIsWeb ? 'browser' : 'platform'} is not supported ⚠️'),
          ),
        TextFormField(
          controller: usernameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Username',
            helperText: usernameNote,
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
            helperText: passwordNote,
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() => obscurePassword = !obscurePassword);
              },
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
          onPressed: () {
            usernameController.text = 'Some-Username';
            passwordController.text = r'Example-P@§$w0rd!';
          },
          child: const Text('Enter sample data'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: isPlatformSupported == true ? requestCredentials : null,
          child: const Text('Request login data'),
        ),
        const SizedBox(height: 8),
        Text('Login-Token: $loginToken'),
      ],
    );
  }
}
