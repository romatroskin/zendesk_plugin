import 'dart:async';
import 'package:meta/meta.dart';

import 'package:flutter/services.dart';

class ZendeskPlugin {
  static const MethodChannel _channel = const MethodChannel('zendesk_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> init({@required String zendeskUrl, @required String appId, @required String clientId}) {
    return _channel.invokeMethod(
      'init',
      {
        'zendeskUrl': zendeskUrl,
        'appId': appId,
        'clientId': clientId,
      },
    );
  }

  static Future<void> setAnonymousIdentity({String name, String email}) {
    return _channel.invokeMethod(
      'setAnonymousIdentity',
      {
        'name': name,
        'email': email,
      },
    );
  }

  static Future<void> setJWTIdentity({String jwtIdentifier}) {
    return _channel.invokeMethod(
      'setJWTIdentity',
      {
        'jwtIdentifier': jwtIdentifier,
      },
    );
  }

  static Future<void> registerPushProvider({String instanceId}) {
    return _channel.invokeMethod(
      'registerPushProvider',
      {
        'instanceId': instanceId,
      },
    );
  }

  static Future<void> showMessagingActivity({bool withAnswerBotEngine = false, bool withSupportEngine = false}) {
    return _channel.invokeMethod(
      'showMessagingActivity',
      {
        'withAnswerBotEngine': withAnswerBotEngine,
        'withSupportEngine': withSupportEngine,
      },
    );
  }

  static Future<void> showHelpCenterActivity({bool withAnswerBotEngine = false, bool withSupportEngine = false}) {
    return _channel.invokeMethod(
      'showHelpCenterActivity',
      {
        'withAnswerBotEngine': withAnswerBotEngine,
        'withSupportEngine': withSupportEngine,
      },
    );
  }

  static Future<void> showViewArticleActivity({
    @required String articleId,
    bool withAnswerBotEngine = false,
    bool withSupportEngine = false,
  }) {
    return _channel.invokeMethod(
      'showViewArticleActivity',
      {
        'articleId': articleId,
        'withAnswerBotEngine': withAnswerBotEngine,
        'withSupportEngine': withSupportEngine,
      },
    );
  }

  static Future<void> showRequestActivity() {
    return _channel.invokeMethod('showRequestActivity');
  }

  static Future<void> showRequestListActivity() {
    return _channel.invokeMethod('showRequestListActivity');
  }
}
