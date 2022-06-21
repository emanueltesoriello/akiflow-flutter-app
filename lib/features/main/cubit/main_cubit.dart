import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/services/analytics_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/user.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  final SentryService _sentryService = locator<SentryService>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

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

  void onLoggedAppStart() {
    User? user = _authCubit.state.user;

    print("onLoggedAppStart user: ${user?.id}");

    if (user != null) {
      _sentryService.authenticate(user.id.toString(), user.email);
    }
  }
}
