import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:models/user.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:async';

class AnalyticsService {
  const AnalyticsService._();
  static const baseUrl = "https://t.akiflow.com/v3/t";
  static final List<Map<String, dynamic>> _eventsBatch = [];
  static Timer? _batchTimer;
  static const batchInterval = Duration(seconds: 1);

  static Future<void> identify({required User user, required String version, required String buildNumber}) async {
    print("*** AnalyticsService identify: ${user.email} ***");

    BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;
    String? deviceId = deviceInfo.toMap()['id'];
    if (deviceId == null) {
      deviceId = deviceInfo.toMap()["identifierForVendor"];
    }

    Map<String, dynamic> traits = {
      "release_mobile": version,
      "mobile_user": true,
      "releaseNumber_mobile": buildNumber,
      "email": user.email,
      "name": user.name,
      "device_id": deviceId,
    };

    if (Config.development) {
      traits["debug"] = "true";
    }

    final body = {
      "id": user.email,
      "email": user.email,
      "traits": traits,
      "properties": {Platform.isAndroid ? "android" : "ios"},
    };

    await http.post(
      Uri.parse('$baseUrl/identify'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<String?> getAnonymousId() async {
    var prefs = await SharedPreferences.getInstance();

    String? anonymousId;

    try {
      anonymousId = prefs.getString('anonymous_id');
    } catch (e) {
      print(e);
    }

    return anonymousId;
  }

  static Future<void> alias(User user) async {
    print("*** AnalyticsService alias: ${user.email} ***");
    String? anonymousId = await getAnonymousId();
    final body = {
      "from": anonymousId,
      "to": user.email,
    };

    await http.post(
      Uri.parse('$baseUrl/alias'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<String?> getUserOrAnonymousId() async {
    var prefs = await SharedPreferences.getInstance();

    String? user;
    String? anonymousId;

    try {
      user = prefs.getString('user');
    } catch (e) {
      print(e);
    }

    if (user == null) {
      try {
        anonymousId = prefs.getString('anonymous_id');
      } catch (e) {
        print(e);
      }

      if (anonymousId == null) {
        anonymousId = const Uuid().v4();
        prefs.setString("anonymous_id", anonymousId);
      }
    } else {
      user = json.decode(user)["email"];
    }
    return user ?? anonymousId;
  }

  static Future<void> track(String event, {Map<String, dynamic>? properties}) async {
    print("*** AnalyticsService track: $event ***");
    try {
      if (properties != null) {
        properties.addAll({"platform": Platform.isAndroid ? "android" : "ios"});
      } else {
        properties = {"platform": Platform.isAndroid ? "android" : "ios"}; // for the superProperties
      }
    } catch (e) {
      print(e);
    }

    const uuid = Uuid();
    final timestamp = DateTime.now().toUtc().toIso8601String();
    String? userOrAnonymousId = "";
    try {
      userOrAnonymousId = await getUserOrAnonymousId();
    } catch (e) {
      print(e);
    }

    _eventsBatch.add({
      "id": uuid.v4(),
      "user_id": userOrAnonymousId,
      "event": event,
      "properties": properties,
      "timestamp": timestamp,
    });

    _batchTimer ??= Timer(batchInterval, _sendBatch);
  }

  static Future<void> _sendBatch() async {
    if (_eventsBatch.isNotEmpty) {
      final body = {"data": _eventsBatch};
      print('Sending batch of events..');
      await http.post(
        Uri.parse('$baseUrl/track'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      _eventsBatch.clear();
    }
    _batchTimer = null; // Reset timer
  }
}
