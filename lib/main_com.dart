import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/strings.g.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/src/base/di/base_providers.dart';
import 'package:mobile/src/base/ui/navigator/base_navigator.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/focus_detector_service.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

FutureOr<SentryEvent?> beforeSend(SentryEvent event, {dynamic hint}) async {
  if (Config.development || SentryService.ignoreException(event.throwable)) {
    return null;
  }
  return event;
}

Future<void> mainCom() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  DatabaseService databaseService = DatabaseService();
  await databaseService.open();
  setupLocator(preferences: preferences, databaseService: databaseService);
  print("environment: ${Config.development ? "dev" : "prod"}");
  await AnalyticsService.config();

  await Intercom.instance.initialize(Config.intercomCredential.appId,
      iosApiKey: Config.intercomCredential.iosApiKey, androidApiKey: Config.intercomCredential.androidApiKey);

  await SentryFlutter.init(
    (options) {
      options.beforeSend = beforeSend;
      options.dsn = Config.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const Application()),
  );
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: ColorsExt.grey5(context),
    ));

    return MultiBlocProvider(
        providers: baseProviders,
        child: Builder(builder: (context) {
          return FocusDetector(
              onForegroundGained: () {
                context.read<MainCubit>().onFocusGained();
              },
              onForegroundLost: () {
                context.read<MainCubit>().onFocusLost();
              },
              child: MaterialApp(
                  title: t.appName,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [Locale('en', 'US')],
                  debugShowCheckedModeBanner: Config.development,
                  navigatorObservers: [routeObserver],
                  theme: lightTheme,
                  home: const BaseNavigator()));
        }));
  }
}
