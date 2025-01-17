import 'package:autologin/autologin.dart';
import 'package:autologin_demo/demo_page.dart';
import 'package:flutter/material.dart';

/// The domain of the demo app
const kDomain = 'rekire.github.io';

void main() {
  AutologinPlugin.setup(
    domain: kDomain,
    appId: 'eu.rekisoft.flutter.autologin',
    appName: 'Autologin Demo',
  );
  runApp(const MaterialApp(home: DemoFrame()));
}

/// This Frame is just to make sure that the DemoPage has a context which can show a snackbar
class DemoFrame extends StatelessWidget {
  const DemoFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autologin-Plugin example app'),
        actions: [
          IconButton(
            tooltip: 'Used libraries',
            icon: const Icon(Icons.developer_mode),
            onPressed: () {
              showLicensePage(context: context);
            },
          ),
        ],
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
    );
  }
}

