import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/label/label.dart';
import 'package:models/user.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  static final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  MainCubit() : super(const MainCubitState()) {
    init();
  }

  init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {}
  }

  void changeHomeView(HomeViewType homeViewType) {
    emit(state.copyWith(homeViewType: homeViewType));
  }

  void selectLabel(Label label) {
    emit(state.copyWith(selectedLabel: label, homeViewType: HomeViewType.label));
  }
}
