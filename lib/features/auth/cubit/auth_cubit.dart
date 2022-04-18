import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:mobile/api/auth_api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/utils/nullable.dart';
import 'package:models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final DialogService _dialogService = locator<DialogService>();
  final AuthApi _authApi = locator<AuthApi>();
  final DatabaseService _databaseService = locator<DatabaseService>();

  final TasksCubit _tasksCubit;
  final SyncCubit _syncCubit;

  AuthCubit(this._tasksCubit, this._syncCubit) : super(const AuthCubitState()) {
    _init();
  }

  _init() async {
    User? user = _preferencesRepository.user;

    print("logged in: ${user != null}");

    if (user != null) {
      if (Config.development) {
        log(user.accessToken?.toString() ?? "");
      }

      emit(AuthCubitState(user: user));
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

      _syncCubit.init();

      emit(state.copyWith(user: Nullable(user)));
    } else {
      _dialogService.showGenericError();
    }
  }

  void logout() {
    _preferencesRepository.clear();

    _databaseService.delete();

    emit(state.copyWith(user: Nullable(null)));

    _tasksCubit.logout();
  }
}
