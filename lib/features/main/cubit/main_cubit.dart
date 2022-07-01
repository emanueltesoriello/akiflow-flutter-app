import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/services/analytics_service.dart';
import 'package:mobile/services/intercom_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/user.dart';
import '../../../extensions/date_extension.dart';

import '../../../api/user_api.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  final SentryService _sentryService = locator<SentryService>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final IntercomService _intercomService = locator<IntercomService>();
  final UserApi _userApi = locator<UserApi>();

  final SyncCubit _syncCubit;
  final AuthCubit _authCubit;

  MainCubit(this._syncCubit, this._authCubit) : super(const MainCubitState()) {
    AnalyticsService.track("Launch");

    User? user = _preferencesRepository.user;

    if (user != null) {
      _syncCubit.sync(loading: true);
      AnalyticsService.track("Show Main Window");
    }
  }

  void changeHomeView(HomeViewType homeViewType) {
    emit(state.copyWith(lastHomeViewType: state.homeViewType));
    emit(state.copyWith(homeViewType: homeViewType));
  }

  void selectLabel() {
    emit(state.copyWith(lastHomeViewType: state.homeViewType));
    emit(state.copyWith(homeViewType: HomeViewType.label));
  }

  void onLoggedAppStart() async {
    User? user = _authCubit.state.user;

    await onFocusGained();
    print("onLoggedAppStart user: ${user?.id}");
  }

  onFocusGained() async {
    User? appUser = _preferencesRepository.user;
    User? user = await _userApi.getUserData();

    DateTime? lastAppUseAt = _preferencesRepository.lastAppUseAt;
    if (user != null && appUser != null) {
      if (DateTime.now().daysBetweenLessThanHundred(lastAppUseAt)) {
        bool? hasValidPlan = DateTime.parse(user.planExpireDate!).isAfter(DateTime.now());
        if (hasValidPlan) {
          _preferencesRepository.saveUser(appUser.copyWith(
              intercomHashIos: user.intercomHashIos,
              intercomHashAndroid: user.intercomHashAndroid,
              status: user.status,
              planExpireDate: user.planExpireDate));
          _sentryService.authenticate(user.id.toString(), user.email);
          await _intercomService.authenticate(
              email: user.email, intercomHashAndroid: user.intercomHashAndroid, intercomHashIos: user.intercomHashIos);
        } else {
          await _authCubit.planExpired();
        }
      } else {
        await _authCubit.logout();
      }
    }
  }

  void onFocusLost() async {
    _preferencesRepository.setLastAppUseAt(DateTime.now());
  }
}
