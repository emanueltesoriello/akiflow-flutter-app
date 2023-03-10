import 'dart:io';

import 'package:flutter_segment/flutter_segment.dart';
import 'package:mobile/core/config.dart';
import 'package:models/user.dart';

class AnalyticsService {
  const AnalyticsService._();

  static Future<void> config() async {
    print("*** AnalyticsService config ***");

    await Segment.config(
      options: SegmentConfig(
        writeKey: Config.segmentApiKey,
        trackApplicationLifecycleEvents: true,
        amplitudeIntegrationEnabled: false,
        debug: Config.development,
      ),
    );
  }

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

    Segment.identify(userId: user.email, traits: traits);
  }

  static Future<void> alias(User user) async {
    String? anonymousId = await Segment.getAnonymousId;

    print("*** AnalyticsService alias: ${user.email}: anonymousId: $anonymousId ***");

    if (anonymousId != null) {
      await Segment.alias(alias: user.email!);
    }
  }

  static void logout() {
    print("*** AnalyticsService logout ***");

    Segment.reset();
  }

  static void track(String event, {Map<String, dynamic>? properties = const {"mobile": true}}) {
    try {
      if (Config.development) {
        print("*** AnalyticsService track: $event ***");
        print(properties);
      }
    } catch (e) {
      print(e);
    }

    Segment.track(eventName: event, properties: properties);
  }
}
