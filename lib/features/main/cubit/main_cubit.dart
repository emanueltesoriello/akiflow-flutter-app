import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/api/user_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/user.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  static final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  final UserApi _userApi = locator<UserApi>();
  final SentryService _sentryService = locator<SentryService>();

  MainCubit() : super(const MainCubitState()) {
    init();
  }

  init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      _sentryService.addBreadcrumb(category: 'user', message: 'Fetching updates');

      User userUpdated = await _userApi.get();

      String accessToken = user.accessToken!;

      userUpdated = userUpdated.copyWith(accessToken: accessToken);

      _preferencesRepository.saveUser(user);

      _sentryService.addBreadcrumb(category: 'user', message: 'Updated');
    }
  }

  void changeHomeView(HomeViewType homeViewType) {
    emit(state.copyWith(homeViewType: homeViewType, selectedLabel: Nullable(null)));
  }

  void selectLabel(Label label) {
    emit(state.copyWith(selectedLabel: Nullable(label), homeViewType: HomeViewType.label));
  }
}
