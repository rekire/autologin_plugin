import 'dart:async';

import 'package:autologin/autologin.dart';
import 'package:autologin_demo/login_fields.dart';
import 'package:autologin_demo/main.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatefulWidget {
  final DateTime firstStart;
  final int starts;
  final String? user;

  const OnboardingPage({
    required this.firstStart,
    this.starts = 0,
    this.user,
    super.key,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();

  /// Starts the onboarding and return the updated login token. Using a
  /// `Completer` is not really the best way IMHO, but good enough for a simple
  /// demo. The matter is that I call this e.g. in initState() where you cannot
  /// navigate, therefore this is done in a micro task.
  static Future<String?> show(BuildContext context, String loginToken) async {
    final completer = Completer<String?>();
    final parts = loginToken.split(';');
    var starts = 1;
    var firstStart = DateTime.now();
    String? lastUser;
    if (parts.length == 3) {
      final ts = int.tryParse(parts.first);
      if (ts != null) {
        firstStart = DateTime.fromMillisecondsSinceEpoch(ts);
      }
      starts = int.tryParse(parts[1]) ?? 1;
      if (parts.last.isNotEmpty) {
        lastUser = parts.last;
      }
    }
    unawaited(
      Future.microtask(
        () {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true)
                .push<String>(
                  MaterialPageRoute<String>(
                    builder: (_) => OnboardingPage(
                      firstStart: firstStart,
                      starts: starts,
                      user: lastUser,
                    ),
                  ),
                )
                .then(completer.complete);
          }
        },
      ),
    );
    return completer.future;
  }
}

class _OnboardingPageState extends State<OnboardingPage> {
  var _shouldRequestCredentials = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final key = GlobalKey<IntroductionScreenState>();
  Credential? fetchedCredentials;

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: key,
      allowImplicitScrolling: true,
      hideBottomOnKeyboard: true,
      canProgress: (page) {
        final last = (key.currentState?.getPagesLength() ?? 0) - 1;
        if (page == last && _shouldRequestCredentials) {
          _shouldRequestCredentials = false;
          AutologinPlugin.requestCredentials().then((credential) async {
            if (mounted) {
              fetchedCredentials = credential;
              if (credential?.username != null &&
                  credential?.password != null) {
                usernameController.text = credential!.username!;
                passwordController.text = credential.password!;
              }
            }
          });
        }
        return true;
      },
      dotsFlex: 4,
      pages: [
        if (widget.user == null)
          PageViewModel(
            title: 'Welcome',
            bodyWidget: _PaddedText(
              '''
to the Autologin sample app.

This is your ${ord(widget.starts)} start of the app.

This example shows how you can use the autologin package in a onboarding flow. For this example is the introduction_screen package used.''',
            ),
          )
        else
          PageViewModel(
            title: 'Welcome back ${widget.user}!',
            bodyWidget: _PaddedText(
              '''
This is your ${ord(widget.starts)} start.

Your first app start was at ${widget.firstStart}

This example shows how you can use the autologin package in a onboarding flow. For this example is the introduction_screen package used.

Since you were detected by the login token you could skip the login and could simply ask for a second factor.''',
              //decoration: pageDecoration,
            ),
          ),
        PageViewModel(
          title: "What's next?",
          bodyWidget: const _PaddedText(
            '''
On the next page you can add enter credentials you like, the input is not validated. After the login the credentials will be stored in your password storage. Depending on your system you might need to confirm it first.

When you have saved any credentials before e.g. on a different device or in the browser, this package will try to get the credentials. Again depending on your system you get a chooser or need to confirm the access the demo credentials of this app.''',
          ),
        ),
        PageViewModel(
          title: 'Login',
          bodyWidget: SizedBox(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  LoginFields(
                    usernameController: usernameController,
                    passwordController: passwordController,
                    onSubmit: (_) => maybeSaveCredentials(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: maybeSaveCredentials,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      usernameController.text = 'Some-Username';
                      passwordController.text = r'Example-P@§$w0rd!';
                    },
                    child: const Text('Enter sample data'),
                  ),
                ],
              ),
            ),
          ),
          decoration: const PageDecoration(
            imagePadding: EdgeInsets.zero,
            contentMargin: EdgeInsets.zero,
            pageMargin: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            footerPadding: EdgeInsets.zero,
            footerFit: FlexFit.tight,
            fullScreen: true,
          ),
        ),
      ],
      next: const Icon(Icons.arrow_forward),
      overrideDone: const SizedBox(height: 28),
      curve: Curves.fastLinearToSlowEaseIn,
      dotsDecorator: const DotsDecorator(
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    );
  }

  void maybeSaveCredentials() {
    if (fetchedCredentials?.username != usernameController.text &&
        fetchedCredentials?.password != passwordController.text &&
        usernameController.text.isNotEmpty) {
      AutologinPlugin.saveCredentials(
        Credential(
          username: usernameController.text,
          password: passwordController.text,
          domain: kDomain,
        ),
      );
    }
    final loginToken = [
      widget.firstStart.millisecondsSinceEpoch,
      widget.starts,
      usernameController.text,
    ].join(';');
    AutologinPlugin.saveLoginToken(loginToken);
    Navigator.pop(context, loginToken);
  }

  // Grammar is hard I try my best...
  String ord(int num) {
    if (num == 1) {
      return 'first';
    } else if (num == 2) {
      return 'second';
    } else if (num == 3) {
      return 'third';
    } else if (num > 4 && num < 20) {
      return '${num}th';
    } else if (num % 10 == 1) {
      return '${num}st';
    } else if (num % 10 == 2) {
      return '${num}nd';
    } else {
      return '${num}th';
    }
  }
}

class _PaddedText extends StatelessWidget {
  final String text;

  const _PaddedText(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(text),
      ),
    );
  }
}
