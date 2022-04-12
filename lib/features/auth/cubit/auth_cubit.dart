import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:mobile/api/auth_api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/utils/nullable.dart';
import 'package:models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final DialogService _dialogService = locator<DialogService>();
  final AuthApi _authApi = locator<AuthApi>();

  final TasksCubit _tasksCubit;

  AuthCubit(this._tasksCubit) : super(const AuthCubitState()) {
    _init();
  }

  _init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      if (Config.development) {
        log(user.accessToken?.toString() ?? "");
      }

      emit(AuthCubitState(user: user));
      _tasksCubit.refresh();
    }
  }

  void loginClick() async {
    FlutterAppAuth appAuth = FlutterAppAuth();

    final AuthorizationResponse? result = await appAuth.authorize(
      AuthorizationRequest(
        Config.oauthClientId,
        Config.oauthRedirectUrl,
        preferEphemeralSession: true,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: Config.oauthEndpoint + '/oauth/authorize',
          tokenEndpoint: Config.oauthEndpoint + '/oauth/authorize',
        ),
      ),
    );

    if (result != null) {
      User user = await _authApi.auth(
          code: result.authorizationCode!, codeVerifier: result.codeVerifier!);

      await _preferencesRepository.saveUser(user);

      _tasksCubit.refresh();

      emit(state.copyWith(user: Nullable(user)));
    } else {
      _dialogService.showGenericError();
    }
  }

  void logoutClick() {
    _preferencesRepository.clear();
    emit(state.copyWith(user: Nullable(null)));

    _tasksCubit.logoutEvent();
  }
}
