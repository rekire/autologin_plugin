import 'dart:async';

import 'package:autologin_plugin/autologin_plugin.dart';
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
    if (!(await AutologinPlugin.isPlatformSupported)) {
      setState(() {
        _username = "not supported";
      });
      return;
    }
    Credential credentials = await AutologinPlugin.getLoginData();
    String username;
    if (credentials != null) {
      username = credentials.username;
    } else {
      username = "<nothing selected>";
    }

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
          child: Icon(Icons.save),
          onPressed: () async {
            if (!(await AutologinPlugin.isPlatformSupported)) {
              setState(() {
                _username = "not supported";
              });
              return;
            }
            AutologinPlugin.saveLoginData(Credential("test", "test"));
          },
        ),
      ),
    );
  }
}
