import 'package:autologin/autologin.dart';
import 'package:autologin_demo/login_fields.dart';
import 'package:autologin_demo/main.dart';
import 'package:autologin_demo/onboarding_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool firstRun = true;

  @override
  Widget build(BuildContext context) {
    const loading = Center(child: CircularProgressIndicator());
    return FutureBuilder(
      future: AutologinPlugin.isPlatformSupported,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading;
        } else if (!snapshot.requireData) {
          const target = kIsWeb ? 'browser' : 'platform';
          return Text(
            'Unfortunately this $target is not supported',
            style: Theme.of(context).textTheme.titleMedium,
          );
        } else {
          return FutureBuilder(
            future: AutologinPlugin.requestLoginToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loading;
              }
              var loginToken = snapshot.data;
              if (loginToken == null || loginToken.isEmpty) {
                loginToken = '${DateTime.now().millisecondsSinceEpoch};1;';
                tryUpdateLoginToken(loginToken);
              } else {
                final parts = loginToken.split(';');
                if (parts.length != 3) {
                  loginToken = '${DateTime.now().millisecondsSinceEpoch};1;';
                  tryUpdateLoginToken(loginToken);
                } else {
                  // first start unix timestamp; app starts; last username
                  loginToken = [
                    parts.first,
                    (int.tryParse(parts[1]) ?? 1) + 1,
                    parts.last,
                  ].join(';');
                  tryUpdateLoginToken(loginToken);
                }
              }
              if (firstRun) {
                firstRun = false;
                return FutureBuilder(
                  future: OnboardingPage.show(context, loginToken),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return loading;
                    }
                    return TextControls(snapshot.data ?? loginToken!);
                  },
                );
              }
              return TextControls(loginToken);
            },
          );
        }
      },
    );
  }

  void tryUpdateLoginToken(String token) {
    AutologinPlugin.saveLoginToken(token).then((success) {
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update login token'),
          ),
        );
      }
    });
  }
}

class TextControls extends StatefulWidget {
  final String loginToken;

  const TextControls(this.loginToken, {super.key});

  @override
  State<TextControls> createState() => _TextControlsState();
}

class _TextControlsState extends State<TextControls> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome to the first start of the example app.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        LoginFields(
          usernameController: usernameController,
          passwordController: passwordController,
          onSubmit: (_) => saveCredentials(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: saveCredentials,
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
          onPressed: requestCredentials,
          child: const Text('Request login data'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final success = await AutologinPlugin.deleteLoginToken();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Login token deleted successfully.'
                        : 'Failed to delete the login token',
                  ),
                ),
              );
            }
          },
          child: const Text('Delete login token'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => OnboardingPage.show(context, widget.loginToken),
          child: const Text('Start onboarding'),
        ),
        const SizedBox(height: 8),
        Text('Login-Token: ${widget.loginToken}'),
      ],
    );
  }

  Future<void> requestCredentials() async {
    final credentials = await AutologinPlugin.requestCredentials();
    updateCredentials(credentials?.username, credentials?.password);
  }

  Future<void> saveCredentials() async {
    final success = await AutologinPlugin.saveCredentials(
      Credential(
        username: usernameController.text,
        password: passwordController.text,
        domain: kDomain,
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
}
