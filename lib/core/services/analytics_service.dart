import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:models/user.dart';
import 'package:mobile/core/config.dart';

class AnalyticsService {
  const AnalyticsService._();
  static const baseUrl = "https://t.akiflow.com/v3/t";

  static Future<void> identify({required User user, required String version, required String buildNumber}) async {
    print("*** AnalyticsService identify: ${user.email} ***");

    Map<String, dynamic> traits = {
      "release_mobile": version,
      "mobile_user": true,
      "releaseNumber_mobile": buildNumber,
      "platform": Platform.isAndroid ? "android" : "ios",
      "email": user.email,
      "name": user.name,
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

  static Future<void> alias(User user) async {
    print("*** AnalyticsService alias: ${user.email} ***");

    final body = {
      "from": "anonymousId",
      "to": user.email,
    };

    await http.post(
      Uri.parse('$baseUrl/alias'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  static Future<void> track(String event, {Map<String, dynamic>? properties = const {"platform": "mobile"}}) async {
    print("*** AnalyticsService track: $event ***");

    const uuid = Uuid();
    final timestamp = DateTime.now().toIso8601String();

    final body = {
      "data": [
        {
          "id": uuid.v4(),
          "user_id": "email OR anonymousId", //TODO -> read email from shared preferences
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
