import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/auth.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:models/user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final DialogService _dialogService = locator<DialogService>();
  final AuthRepository _authRepository = locator<AuthRepository>();

  AuthCubit() : super(const AuthCubitState()) {
    _init();
  }

  _init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      emit(AuthCubitState(user: user));
    }
  }

  void loginClick() async {
    FlutterAppAuth appAuth = FlutterAppAuth();

    final AuthorizationResponse? result = await appAuth.authorize(
      AuthorizationRequest(
        Config.oauthClientId,
        Config.oauthRedirectUrl,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: Config.oauthEndpoint + '/oauth/authorize',
          tokenEndpoint: Config.oauthEndpoint + '/redirect/token',
        ),
      ),
    );

    if (result != null) {
      User user = await _authRepository.auth(
          code: result.authorizationCode!, codeVerifier: result.codeVerifier!);

      await _preferencesRepository.saveUser(user);

      emit(state.copyWith(user: user));
    } else {
      _dialogService.showGenericError();
    }
  }
}
