import 'dart:convert';

import 'package:flutter/services.dart';

abstract class Config {
  static late Map<String, dynamic> _config;
  static late bool _development;

  /// Inizialize [Config] class
  ///
  /// Pass [development] true when launch production main (main_prod.dart) and
  /// and the config file of interest
  static Future<void> initialize({
    required bool production,
    required String configFile,
  }) async {
    final configString = await rootBundle.loadString(configFile);
    _config = json.decode(configString) as Map<String, dynamic>;
    _development = production == false;
  }

  static String get endpoint {
    return _config['endpoint'] as String;
  }

  static String get oauthEndpoint {
    return _config['oauth_endpoint'] as String;
  }

  static bool get development {
    return _development;
  }

  static String get sentryDsn {
    return _config['sentry_dsn'] as String;
  }

  static String get oauthClientId {
    return _config['oauth_client_id'] as String;
  }

  static String get oauthRedirectUrl {
    return _config['oauth_redirect_url'] as String;
  }

  static GoogleCredentials get googleCredentials {
    return GoogleCredentials(
      _config['google_credentials']['client_id_android'] as String,
      _config['google_credentials']['client_id_ios'] as String,
    );
  }

  static String get segmentApiKey {
    return _config['segment_api_key'] as String;
  }

  static IntercomCredential get intercomCredential {
    return IntercomCredential(
      appId: _config['intercom']['app_id'] as String,
      iosApiKey: _config['intercom']['ios_api_key'] as String,
      androidApiKey: _config['intercom']['android_api_key'] as String,
    );
  }

  static GooglePlacesCredentials get googlePlacesCredentials {
    return GooglePlacesCredentials(
      androidApiKey: _config['google_places']['android_api_key'] as String,
      iosApiKey: _config['google_places']['ios_api_key'] as String,
    );
  }
}

class GoogleCredentials {
  final String clientIdAndroid;
  final String clientIdiOS;

  GoogleCredentials(this.clientIdAndroid, this.clientIdiOS);
}

class IntercomCredential {
  final String appId;
  final String iosApiKey;
  final String androidApiKey;

  IntercomCredential({required this.appId, required this.iosApiKey, required this.androidApiKey});
}

class GooglePlacesCredentials {
  final String androidApiKey;
  final String iosApiKey;

  GooglePlacesCredentials({required this.androidApiKey, required this.iosApiKey});
}
