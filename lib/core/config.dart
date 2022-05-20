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

  /// Sentry DSN based on the environment
  static String get sentryDsn {
    return _config['sentry_dsn'] as String;
  }

  static String get oauthClientId {
    return _config['oauth_client_id'] as String;
  }

  static String get oauthRedirectUrl {
    return _config['oauth_redirect_url'] as String;
  }

  static String get pusherInstanceId {
    return _config['pusher_instance_id'] as String;
  }
}
