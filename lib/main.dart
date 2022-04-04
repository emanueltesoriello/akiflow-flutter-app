import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/main_com.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

FutureOr<SentryEvent?> beforeSend(SentryEvent event, {dynamic hint}) async {
  if (SentryService.ignoreException(event.throwable)) {
    return null;
  }

  return event;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the [Config] class based on the parameter received as file path
  await Config.initialize(true, 'assets/config/prod.json');

  await SentryFlutter.init(
    (options) {
      options.beforeSend = beforeSend;
      options.dsn = Config.sentryDsn();
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => mainCom(),
  );
}
