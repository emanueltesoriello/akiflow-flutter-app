import 'dart:isolate';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/api/user_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/intercom_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:models/user.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'main_state.dart';

bool shouldForceLogOut(DateTime? to) {
  if (to != null) {
    to = DateTime(to.year, to.month, to.day);
    return (DateTime.now().difference(to).inHours / 24) < 100;
  }
  return true;
}

class MainCubit extends Cubit<MainCubitState> {
  final SentryService _sentryService = locator<SentryService>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final IntercomService _intercomService = locator<IntercomService>();
  final UserApi _userApi = locator<UserApi>();

  final SyncCubit _syncCubit;
  final AuthCubit _authCubit;
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();

  // *********************************
  // *********************************

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
      if (shouldForceLogOut(lastAppUseAt)) {
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
          try {
            // trigger that start every time the set port is called
            // used for handling backgroundSync that update the UI
            var port = ReceivePort();
            IsolateNameServer.registerPortWithName(port.sendPort, "backgroundSync");
            port.listen((dynamic data) async {
              print('got $data on UI');
              _syncControllerService.sync();
            });
          } catch (e) {
            print(e);
          }
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
    _syncControllerService.sync([Entity.tasks]);
  }
}
