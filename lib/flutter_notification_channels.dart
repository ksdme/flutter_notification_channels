import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterNotificationChannels {
  static const MethodChannel _channel =
      const MethodChannel('flutter_notification_channels');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> get areChannelsSupported async {
    return await _channel.invokeMethod('areChannelsSupported');
  }

  /*
    Creates a new channel.
  */
  static Future<bool> createChannel({
    @required String id,
    @required String name,
    @required String description,
    bool lights=true,
    bool vibrate=true,
    String sound='default',
  }) async {
    return await _channel.invokeMethod('createChannel', {
      'id': id,
      'name': name,
      'description': description,
      'sound': sound,
      'lights': lights ? 'true' : 'false',
      'vibrate': vibrate ? 'true' : 'false',
    });
  }

  /*
    Removes a registered notification channel.
  */
  static Future<bool> removeChannel(String channel) async {
    return await _channel.invokeMethod('removeChannel', channel);
  }
}
