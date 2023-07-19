import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/api/auth_api.dart';
import 'package:mobile/core/api/client_api.dart';
import 'package:mobile/core/api/user_api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/dialog_service.dart';
import 'package:mobile/src/base/ui/pages/auth_page.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import './../../../../../extensions/local_notifications_extensions.dart';
import 'package:mobile/core/services/navigation_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/main_com.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:models/client/client.dart';
import 'package:models/nullable.dart';
import 'package:models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final DialogService _dialogService = locator<DialogService>();
  final AuthApi _authApi = locator<AuthApi>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final SentryService _sentryService = locator<SentryService>();
  //final IntercomService _intercomService = locator<IntercomService>();

  final UserApi _userApi = locator<UserApi>();

  final SyncCubit _syncCubit;

  AuthCubit(this._syncCubit) : super(const AuthCubitState()) {
    _init();
  }

  planExpired() async {
    User? user = _preferencesRepository.user;
    emit(AuthCubitState(hasValidPlan: false, user: user));
  }

  _init() async {
    User? user = _preferencesRepository.user;
    bool? hasValidPlan = await _userApi.hasValidPlan();

    if (hasValidPlan == true) {
      emit(AuthCubitState(user: user));
      print("logged in: ${user != null}");

      if (user != null) {
        if (Config.development) {
          log(user.accessToken?.toString() ?? "");
        }

        _sentryService.addBreadcrumb(category: 'user', message: 'Fetching updates');

        Map<String, dynamic>? remoteSettings = await _userApi.getSettings();
        Map<String, dynamic>? localSettings = user.settings;

        if (remoteSettings != null) {
          Map<String, dynamic>? mergedSettings =
              UserSettingsUtils.compareRemoteWithLocal(remoteSettings: remoteSettings, localSettings: localSettings);
          user = user.copyWith(settings: mergedSettings);
        }

        await _preferencesRepository.saveUser(user);

        emit(state.copyWith(user: Nullable(user)));

        _sentryService.addBreadcrumb(category: 'user', message: 'Updated');
        //_intercomService.authenticate(
        //    email: user.email, intercomHashAndroid: user.intercomHashAndroid, intercomHashIos: user.intercomHashIos);
      }
    } else {
      emit(AuthCubitState(hasValidPlan: false, user: user));
    }
  }

  void loginClick() async {
    AnalyticsService.track("Login started");

    FlutterAppAuth appAuth = const FlutterAppAuth();

    final AuthorizationResponse? result = await appAuth.authorize(
      AuthorizationRequest(
        Config.oauthClientId,
        Config.oauthRedirectUrl,
        preferEphemeralSession: true,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: '${Config.oauthEndpoint}/oauth/authorize',
          tokenEndpoint: '${Config.oauthEndpoint}/oauth/authorize',
        ),
      ),
    );

    if (result != null && result.authorizationCode != null && result.codeVerifier != null) {
      User? user = await _authApi.auth(code: result.authorizationCode!, codeVerifier: result.codeVerifier!);
      if (user != null) {
        await _preferencesRepository.saveUser(user);
        bool hasValidPlan = await _userApi.hasValidPlan();

        if (hasValidPlan) {
          try {
            Map<String, dynamic>? settings = await _userApi.getSettings();

            if (settings != null) {
              user = user.copyWith(settings: settings);
              await _preferencesRepository.saveUser(user);
            }
          } catch (_) {}

          _sentryService.authenticate(user!.id.toString(), user.email);

          try {
            emit(state.copyWith(user: Nullable(user), hasValidPlan: hasValidPlan));
          } catch (e) {
            print(e);
          }

          try {
            _syncCubit.sync();
          } catch (e) {
            print(e);
          }

          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String version = packageInfo.version;
          String buildNumber = packageInfo.buildNumber;

          await AnalyticsService.alias(user);
          AnalyticsService.identify(user: user, version: version, buildNumber: buildNumber);
        } else {
          emit(state.copyWith(user: Nullable(user), hasValidPlan: false));
        }
      } else {
        emit(state.copyWith(user: Nullable(user)));
      }
    } else {
      _dialogService.showGenericError();
    }
  }

  Future _onLogoutPostClient() async {
    try {
      ApiClient api = ClientApi();
      String id = _preferencesRepository.deviceUUID;
      int userId = _preferencesRepository.user!.id ?? 0;

      Client client = Client(id: id, userId: userId, notificationsToken: null);

      await api.postClient(client: client.toMap(), keepFCMTokenToNull: true);

      return;
    } catch (e, s) {
      _sentryService.captureException(e, stackTrace: s);
    }
  }

  Future<void> logout() async {
    _sentryService.addBreadcrumb(category: "action", message: "logout");

    await _onLogoutPostClient();

    //Cancel notifications
    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localNotificationsPlugin.cancelAllExt();

    await _databaseService.delete();

    await locator<TasksCubit>().refreshAllFromRepository();

    await _preferencesRepository.clear();

    //restart the app to clean all the local variables
    try {
      BuildContext? context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        print('calling Phoenix.rebirth');

        await locator.reset();
        locator = GetIt.instance;

        initFunctions();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (BuildContext context) => const AuthPage()),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      print('catched error on logout');
      print(e);
    }

    emit(state.copyWith(user: Nullable(null)));

    AnalyticsService.logout();
  }

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    Map<String, dynamic>? updated = await pushLocalSettingToRemote(settings);

    if (updated != null) {
      User user = _preferencesRepository.user!;
      user = user.copyWith(settings: updated);
      _preferencesRepository.saveUser(user);
      emit(state.copyWith(user: Nullable(user)));
    }
  }

  Future<Map<String, dynamic>?> pushLocalSettingToRemote(Map<String, dynamic> settings) async {
    String id = _preferencesRepository.deviceUUID;
    Map<String, dynamic>? updated = await _userApi.postSettings(id, settings);
    return updated;
  }

  void updateSection({required String sectionName, required List<dynamic> section}) {
    Map<String, dynamic>? settings = _preferencesRepository.user?.settings;

    settings?[sectionName] = section;

    User user = _preferencesRepository.user!;
    user = user.copyWith(settings: settings);
    _preferencesRepository.saveUser(user);

    emit(state.copyWith(user: Nullable(user)));
  }

  dynamic getSettingBySectionAndKey({required String sectionName, required String key}) {
    return UserSettingsUtils.getSettingBySectionAndKey(
        preferencesRepository: _preferencesRepository, sectionName: sectionName, key: key);
  }
}
