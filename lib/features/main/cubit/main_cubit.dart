import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/user.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  static final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();

  MainCubit() : super(const MainCubitState()) {
    init();
  }

  init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {}
  }

  void changeHomeView(int index) {
    switch (index) {
      case 1:
        emit(state.copyWith(homeViewType: HomeViewType.inbox));
        break;
      case 2:
        emit(state.copyWith(homeViewType: HomeViewType.today));
        break;
      case 3:
        emit(state.copyWith(homeViewType: HomeViewType.calendar));
        break;
    }
  }
}
