import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/strings.g.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/features/dialog/dialog_cubit.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/integrations/cubit/integrations_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/ui/main_page.dart';
import 'package:mobile/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:mobile/features/push/cubit/push_cubit.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';
import 'package:models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/ui/trial_expired_page.dart';
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

  bool userLogged =
      locator<PreferencesRepository>().user != null && locator<PreferencesRepository>().user!.accessToken != null;

  print("environment: ${Config.development ? "dev" : "prod"}");

  await AnalyticsService.config();

  if (userLogged) {
    _identifyAnalytics(locator<PreferencesRepository>().user!);
  }
  await Intercom.instance.initialize(Config.intercomCredential.appId,
      iosApiKey: Config.intercomCredential.iosApiKey, androidApiKey: Config.intercomCredential.androidApiKey);

  await SentryFlutter.init(
    (options) {
      options.beforeSend = beforeSend;
      options.dsn = Config.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(Application(userLogged: userLogged)),
  );
}

_identifyAnalytics(User user) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  await AnalyticsService.identify(user: user, version: version, buildNumber: buildNumber);
}

bool dialogShown = false;

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
        providers: [
          BlocProvider<DialogCubit>(
            lazy: false,
            create: (BuildContext context) => DialogCubit(),
          ),
          BlocProvider<PushCubit>(
            lazy: false,
            create: (BuildContext context) => locator<PushCubit>(),
          ),
          BlocProvider<SyncCubit>(
            lazy: false,
            create: (BuildContext context) => locator<SyncCubit>(),
          ),
          BlocProvider<TasksCubit>(
            lazy: false,
            create: (BuildContext context) => locator<TasksCubit>(),
          ),
          BlocProvider<LabelsCubit>(
            lazy: false,
            create: (BuildContext context) => LabelsCubit(locator<SyncCubit>()),
          ),
          BlocProvider<MainCubit>(
            lazy: false,
            create: (BuildContext context) => MainCubit(locator<SyncCubit>(), locator<AuthCubit>()),
          ),
          BlocProvider<AuthCubit>(
            lazy: false,
            create: (BuildContext context) => locator<AuthCubit>(),
          ),
          BlocProvider<SettingsCubit>(
            lazy: false,
            create: (BuildContext context) => SettingsCubit(),
          ),
          BlocProvider<IntegrationsCubit>(
            lazy: false,
            create: (BuildContext context) => IntegrationsCubit(locator<AuthCubit>(), locator<SyncCubit>()),
          ),
          BlocProvider<TodayCubit>(
            lazy: false,
            create: (BuildContext context) => locator<TodayCubit>(),
          ),
          BlocProvider<EditTaskCubit>(
            lazy: false,
            create: (BuildContext context) => EditTaskCubit(locator<TasksCubit>(), locator<SyncCubit>()),
          ),
          BlocProvider<OnboardingCubit>(
            lazy: false,
            create: (BuildContext context) => OnboardingCubit(),
          ),
        ],
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
                home: BlocListener<AuthCubit, AuthCubitState>(
                  listener: (context, state) {
                    if (state.hasValidPlan == false) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                        builder: (BuildContext context) => const TrialExpiredPage(),
                      ));
                    }
                    if (state.user == null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
                        builder: (BuildContext context) => const AuthPage(),
                      ));
                    }
                  },
                  child: _Home(userLogged: userLogged),
                ),
              ));
        }));
  }
}

class _Home extends StatelessWidget {
  const _Home({
    Key? key,
    required this.userLogged,
  }) : super(key: key);

  final bool userLogged;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DialogCubit, DialogState>(
      listener: (context, state) {
        if (state is DialogShowMessage) {
          if (dialogShown) {
            return;
          }

          dialogShown = true;

          Timer(
            const Duration(milliseconds: 1000),
            () {
              dialogShown = false;
            },
          );

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(state.action.title, style: TextStyle(color: ColorsExt.grey1(context))),
              content: state.action.content != null
                  ? Text(state.action.content!, style: TextStyle(color: ColorsExt.grey1(context)))
                  : null,
              actions: <Widget>[
                state.action.dismiss != null
                    ? TextButton(
                        child: Text(state.action.dismissTitle ?? t.dismiss),
                        onPressed: () {
                          Navigator.pop(context);
                          state.action.dismiss!();
                        },
                      )
                    : const SizedBox(),
                TextButton(
                  child: Text(state.action.confirmTitle ?? t.ok),
                  onPressed: () {
                    Navigator.pop(context);
                    if (state.action.confirm != null) {
                      state.action.confirm!();
                    }
                  },
                ),
              ],
            ),
          );
        }
      },
      child: Builder(
        builder: (context) {
          if (userLogged) {
            return const MainPage();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
