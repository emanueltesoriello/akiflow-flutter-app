import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/account/auth/cubit/auth_cubit.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'base_state.dart';

class BaseCubit extends Cubit<BaseCubitState> {
  /*ExampleCubit(super.initialState) : super() {
    initFunc();
  }*/

  BaseCubit() : super(const BaseCubitState()) {
    init();
  }

  // ************ INIT FUNCTIONS ************
  // ****************************************
  init() async {
    /* bool userLogged = false;
    bool dialogShown = false;

    userLogged =
        locator<PreferencesRepository>().user != null && locator<PreferencesRepository>().user!.accessToken != null;

    emit(state.copyWith(hasValidPlan: userLogged, dialogShown: dialogShown));
    if (userLogged) {
      _identifyAnalytics(locator<PreferencesRepository>().user!);
    }*/
    emit(state.copyWith(hasValidPlan: true));

    /*Timer(Duration(seconds: 1), () {
      emit(state.copyWith(hasValidPlan: false));
    });*/
    // notifyListeners();
    // hasValidPlan =
    locator<AuthCubit>().stream.listen((authState) => emit(state.copyWith(hasValidPlan: authState.hasValidPlan)));
    locator<AuthCubit>().stream.listen((authState) => emit(state.copyWith(userLogged: authState.user != null)));
    //locator<DialogCubit>().stream.listen((state) => dialogShown = state is DialogShowMessage);
  }

  _identifyAnalytics(User user) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    await AnalyticsService.identify(user: user, version: version, buildNumber: buildNumber);
  }
}
