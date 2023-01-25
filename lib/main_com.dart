import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/strings.g.dart';
//import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/src/base/di/base_providers.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/navigator/base_navigator.dart';
import 'package:models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/focus_detector_service.dart';
import 'package:timezone/data/latest.dart' as tz;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

FutureOr<SentryEvent?> beforeSend(SentryEvent event, {dynamic hint}) async {
  if (Config.development || SentryService.ignoreException(event.throwable)) {
    return null;
  }
  return event;
}

Future<void> initFunctions() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  DatabaseService databaseService = DatabaseService();

  tz.initializeTimeZones();
  await databaseService.open();
  setupLocator(preferences: preferences, databaseService: databaseService);
  bool userLogged =
      locator<PreferencesRepository>().user != null && locator<PreferencesRepository>().user!.accessToken != null;
  print("environment: ${Config.development ? "dev" : "prod"}");
  await AnalyticsService.config();
  if (userLogged) {
    _identifyAnalytics(locator<PreferencesRepository>().user!);
  }
  //await Intercom.instance.initialize(Config.intercomCredential.appId,
  //    iosApiKey: Config.intercomCredential.iosApiKey, androidApiKey: Config.intercomCredential.androidApiKey);

  // Init Background Service and register periodic task
  BackgroundService.initBackgroundService();
  BackgroundService.registerPeriodicTask(const Duration(minutes: 15));
}

_identifyAnalytics(User user) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;
  await AnalyticsService.identify(user: user, version: version, buildNumber: buildNumber);
}

Future<void> mainCom({kDebugMode = false}) async {
  await initFunctions();

  bool userLogged =
      locator<PreferencesRepository>().user != null && locator<PreferencesRepository>().user!.accessToken != null;
  await SentryFlutter.init((options) {
    options.beforeSend = beforeSend;
    options.dsn = Config.sentryDsn;
    options.tracesSampleRate = 1.0;
  },
      appRunner: () => runApp(
            DevicePreview(enabled: kDebugMode, builder: (context) => Application(userLogged: userLogged)),
          ));
}

class Application extends StatelessWidget {
  final bool userLogged;

  const Application({
    Key? key,
    required this.userLogged,
  }) : super(key: key);

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
                  home: BaseNavigator(userLogged: userLogged)));
        }));
  }
}
