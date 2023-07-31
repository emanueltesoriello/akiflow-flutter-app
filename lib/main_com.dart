import 'dart:async';
import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/navigation_service.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:mobile/src/base/di/base_providers.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/navigator/base_navigator.dart';
import 'package:mobile/src/settings/ui/pages/general_settings_page.dart';
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
  // DatabaseService databaseService = DatabaseService.dbProvider;

  tz.initializeTimeZones();
  if (DatabaseService.database == null || !DatabaseService.database!.isOpen) {
    await DatabaseService.dbProvider.open();
    print('new database opened - initFunctions');
  } else {
    print('database already opened - initFunctions');
  }
  setupLocator(preferences: preferences);
  bool userLogged =
      locator<PreferencesRepository>().user != null && locator<PreferencesRepository>().user!.accessToken != null;
  print("environment: ${Config.development ? "dev" : "prod"}");
  //await AnalyticsService.config();
  if (userLogged) {
    _identifyAnalytics(locator<PreferencesRepository>().user!);
  }

  // Init Background Service and register periodic task
  await BackgroundService.cancelServices();
  await BackgroundService.initBackgroundService();
  if (Platform.isAndroid) {
    BackgroundService.registerPeriodicTask(const Duration(minutes: 15));
  }
  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      print(e);
    }
  }
}

_identifyAnalytics(User user) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;
  await AnalyticsService.identify(user: user, version: version, buildNumber: buildNumber);
}

Future<void> mainCom({kDebugMode = false}) async {
  await initFunctions();

  await SentryFlutter.init((options) {
    options.beforeSend = beforeSend;
    options.dsn = Config.sentryDsn;
    options.tracesSampleRate = 1.0;
  },
      appRunner: () => runApp(
            DevicePreview(enabled: kDebugMode, builder: (context) => const RestartWidget(child: Application())),
          ));
}

class Application extends StatefulWidget {
  const Application({
    Key? key,
  }) : super(key: key);

  @override
  State<Application> createState() => ApplicationState();

  static ApplicationState of(BuildContext context) => context.findAncestorStateOfType<ApplicationState>()!;
}

class ApplicationState extends State<Application> {
  String theme = ThemeOptions.system;

  @override
  void initState() {
    theme = UserSettingsUtils.getSettingBySectionAndKey(
            preferencesRepository: locator<PreferencesRepository>(),
            sectionName: UserSettingsUtils.generalSection,
            key: UserSettingsUtils.theme) ??
        ThemeOptions.system;
    super.initState();
  }

  void changeTheme(String themeMode) {
    setState(() {
      theme = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent
        ));

    return MultiBlocProvider(
        providers: baseProviders,
        child: Builder(builder: (context) {
          bool userLogged = locator<PreferencesRepository>().user != null &&
              locator<PreferencesRepository>().user!.accessToken != null;
          return FocusDetector(
              onForegroundGained: () {
                context.read<MainCubit>().onFocusGained();
              },
              onForegroundLost: () {
                context.read<MainCubit>().onFocusLost();
              },
              child: MaterialApp(
                  key: GlobalKey(),
                  navigatorKey: NavigationService.navigatorKey,
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
                  darkTheme: darkTheme,
                  themeMode: ThemeOptions.themeOptionToThemeMode(theme),
                  home: FutureBuilder(
                      future: NotificationsService.handlerForNotificationsClickForTerminatedApp(),
                      builder: (context, _) {
                        return BaseNavigator(userLogged: userLogged);
                      })));
        }));
  }
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static Future restartApp(BuildContext context) async {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
    await initFunctions();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
