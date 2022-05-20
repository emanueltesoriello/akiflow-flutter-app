import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/api/auth_api.dart';
import 'package:mobile/api/user_api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/push_notification_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/nullable.dart';
import 'package:models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final DialogService _dialogService = locator<DialogService>();
  final AuthApi _authApi = locator<AuthApi>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final SentryService _sentryService = locator<SentryService>();
  final UserApi _userApi = locator<UserApi>();


  final TasksCubit _tasksCubit;
  final LabelsCubit _labelsCubit;

  AuthCubit(this._tasksCubit, this._labelsCubit) : super(const AuthCubitState()) {
    _init();
  }

  _init() async {
    User? user = _preferencesRepository.user;

    print("logged in: ${user != null}");

    if (user != null) {
      if (Config.development) {
        log(user.accessToken?.toString() ?? "");
      }

      _sentryService.authenticate(user.id.toString(), user.email);

      _sentryService.addBreadcrumb(category: 'user', message: 'Fetching updates');

      User userUpdated = await _userApi.get();



      String accessToken = user.accessToken!;

      userUpdated = userUpdated.copyWith(accessToken: accessToken);

      _preferencesRepository.saveUser(user);

      emit(AuthCubitState(user: user));

      _sentryService.addBreadcrumb(category: 'user', message: 'Updated');
    }
  }

  void loginClick() async {
    FlutterAppAuth appAuth = const FlutterAppAuth();

    final AuthorizationResponse? result = await appAuth.authorize(
      AuthorizationRequest(
        Config.oauthClientId,
        Config.oauthRedirectUrl,
        // preferEphemeralSession: true,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: '${Config.oauthEndpoint}/oauth/authorize',
          tokenEndpoint: '${Config.oauthEndpoint}/oauth/authorize',
        ),
      ),
    );

    if (result != null) {
      User user = await _authApi.auth(code: result.authorizationCode!, codeVerifier: result.codeVerifier!);

      await _preferencesRepository.saveUser(user);

      _sentryService.authenticate(user.id.toString(), user.email);

      emit(state.copyWith(user: Nullable(user)));

      _tasksCubit.syncAllAndRefresh();
      _labelsCubit.syncAllAndRefresh(loading: true);
    } else {
      _dialogService.showGenericError();
    }
  }

  void logout() {
    _sentryService.addBreadcrumb(category: "action", message: "logout");

    _preferencesRepository.clear();

    _databaseService.delete();

    emit(state.copyWith(user: Nullable(null)));

    _tasksCubit.logout();
  }
}
