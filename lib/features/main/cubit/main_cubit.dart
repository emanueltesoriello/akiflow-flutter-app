import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainCubitState> {
  MainCubit() : super(const MainCubitState());

  void changeHomeView(HomeViewType homeViewType) {
    emit(state.copyWith(homeViewType: homeViewType, selectedLabel: Nullable(null)));
  }

  void selectLabel(Label label) {
    emit(state.copyWith(selectedLabel: Nullable(label), homeViewType: HomeViewType.label));
  }
}
