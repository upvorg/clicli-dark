import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPlugin {
  static const CHANNEL_NAME = "tech.shmy.plugins/flutter_dlan/";
  static const MethodChannel methodChannel =
      const MethodChannel(CHANNEL_NAME + "method_channel");
  static const EventChannel eventChannel =
      const EventChannel(CHANNEL_NAME + "event_channel");
  static StreamSubscription eventSubscription;

  static init(cb) {
    eventSubscription =
        eventChannel.receiveBroadcastStream().listen((dynamic data) {
      cb(data);
    });
  }

  static search() async {
    await methodChannel.invokeMethod('search');
  }

  static Future<List<dynamic>> get devices async {
    final List<dynamic> devices =
        await methodChannel.invokeListMethod("getList");
    return devices;
  }

  static connectDevice() async {
    var argument = {
      'position': "0",
    };
    await methodChannel.invokeMethod('connectDevice', argument);
  }

  static playLocalSource(var argument) async {
//    var argument = {
//      'title': "title",
//    };
    await methodChannel.invokeMethod("playLocal", argument);
  }

  static stopPlay() async {
    await methodChannel.invokeMethod("stopPlay");
  }

  static Future<List<dynamic>> get localImages async {
    final List<dynamic> getLocalImages =
        await methodChannel.invokeListMethod("getLocalImages");
    return getLocalImages;
  }

  static Future<List<dynamic>> get localVideos async {
    final List<dynamic> getLocalImages =
        await methodChannel.invokeListMethod("localVideos");
    return getLocalImages;
  }

  static Future<List<dynamic>> get localAudios async {
    final List<dynamic> getLocalImages =
        await methodChannel.invokeListMethod("localAudios");
    return getLocalImages;
  }
}
