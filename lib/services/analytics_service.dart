import 'dart:io';

import 'package:flutter_segment/flutter_segment.dart';
import 'package:mobile/core/config.dart';
import 'package:models/user.dart';

class AnalyticsService {
  Future<void> config() async {
    print("*** AnalyticsService config ***");

    await Segment.config(
      options: SegmentConfig(
        writeKey: Config.segmentApiKey,
        trackApplicationLifecycleEvents: false,
        amplitudeIntegrationEnabled: false,
        debug: Config.development,
      ),
    );
  }

  Future<void> identify({required User user, required String version, required String buildNumber}) async {
    print("*** AnalyticsService identify: ${user.email} ***");

    Map<String, dynamic> traits = {
      "release": version,
      "releaseNumber": buildNumber,
      "platform": Platform.isAndroid ? "android" : "ios",
      "email": user.email,
      "name": user.name,
    };

    if (Config.development) {
      traits["debug"] = "true";
    }

    Segment.identify(userId: user.email, traits: traits);
  }

  Future<void> alias(User user) async {
    String? anonymousId = await Segment.getAnonymousId;

    print("*** AnalyticsService alias: ${user.email}: anonymousId: $anonymousId ***");

    if (anonymousId != null) {
      await Segment.alias(alias: user.email!);
    }
  }

  Future<void> logout() async {
    print("*** AnalyticsService logout ***");

    await Segment.reset();
  }
}
