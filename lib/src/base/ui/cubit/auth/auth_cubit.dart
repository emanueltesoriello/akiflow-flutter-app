import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:mobile/core/services/intercom_service.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
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

        Map<String, dynamic>? settings = await _userApi.getSettings();

        if (settings != null) {
          user = user.copyWith(settings: settings);
        }

        _preferencesRepository.saveUser(user);

        emit(AuthCubitState(user: user));

        _sentryService.addBreadcrumb(category: 'user', message: 'Updated');
        //_intercomService.authenticate(
        //   email: user.email, intercomHashAndroid: user.intercomHashAndroid, intercomHashIos: user.intercomHashIos);
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
            NotificationsService.scheduleNotificationsService(locator<PreferencesRepository>());
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

    _onLogoutPostClient();

    _preferencesRepository.clear();

    _databaseService.delete();

    emit(state.copyWith(user: Nullable(null)));

    AnalyticsService.logout();
  }

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    User user = User.fromMap(state.user!.toMap());

    user = user.copyWith(settings: settings);

    emit(state.copyWith(user: Nullable(const User())));
    emit(state.copyWith(user: Nullable(user)));

    Map<String, dynamic>? updated = await _userApi.postSettings(settings);

    if (updated != null) {
      user = user.copyWith(settings: updated);
      _preferencesRepository.saveUser(user);
    }
  }
}
