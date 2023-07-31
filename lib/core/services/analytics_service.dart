import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:models/user.dart';
import 'package:mobile/core/config.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AnalyticsService {
  const AnalyticsService._();
  static const baseUrl = "https://t.akiflow.com/v3/t";

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
      "platform": Platform.isAndroid ? "android" : "ios",
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
      "properties": {"platform": "mobile"},
      "traits": traits,
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

  static Future<void> track(String event, {Map<String, dynamic>? properties = const {"platform": "mobile"}}) async {
    print("*** AnalyticsService track: $event ***");

    const uuid = Uuid();
    final timestamp = DateTime.now().toIso8601String();
    String? userOrAnonymousId = "";
    try {
      userOrAnonymousId = await getUserOrAnonymousId();
    } catch (e) {
      print(e);
    }

    final body = {
      "data": [
        {
          "id": uuid.v4(),
          "user_id": userOrAnonymousId,
          "event": event,
          "properties": properties,
          "timestamp": timestamp
        }
      ]
    };

    await http.post(
      Uri.parse('$baseUrl/track'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }
}
