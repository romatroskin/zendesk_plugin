import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zendesk_plugin/zendesk_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await ZendeskPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              FlatButton(
                child: Text('Show Help Center'),
                onPressed: () async {
                  await ZendeskPlugin.init(
                    zendeskUrl: 'https://sircorp.zendesk.com',
                    appId: '6d163b81c09dcdc095ed328db69a3ef386a59463489b3b92',
                    clientId: 'mobile_sdk_client_e631681d57d8ad530c3d',
                  );
                  await ZendeskPlugin.setAnonymousIdentity(name: 'Name', email: 'email@email.com');
                  await ZendeskPlugin.showHelpCenterActivity(
                    withAnswerBotEngine: true,
                    withSupportEngine: true,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
