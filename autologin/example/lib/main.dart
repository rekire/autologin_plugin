import 'dart:async';

import 'package:autologin/autologin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _username = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!AutologinPlugin.isPlatformSupported) {
      setState(() {
        _username = '<This platform is not supported>';
      });
      return;
    }

    final credentials = await AutologinPlugin.requestCredentials();
    final username = credentials?.username ?? '<No username given>';

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _username = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Autologin-Plugin example app'),
        ),
        body: Center(
          child: Text('Selected account: $_username'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () async {
            if (!AutologinPlugin.isPlatformSupported) {
              // TODO(rekire): replace by toast
              setState(() {
                _username = 'not supported';
              });
              return;
            }
            await AutologinPlugin.saveCredentials(const Credential(
              username: 'Some-Username',
              password: r'Example-P@§$w0rd!',
            ));
          },
        ),
      ),
    );
  }
}
