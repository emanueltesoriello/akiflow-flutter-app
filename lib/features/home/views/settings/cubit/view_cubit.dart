import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'view_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  SettingsCubit() : super(const SettingsCubitState()) {
    _init();
  }

  _init() async {}
}
