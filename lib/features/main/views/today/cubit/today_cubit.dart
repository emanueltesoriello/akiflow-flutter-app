import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayCubitState> {
  TodayCubit() : super(const TodayCubitState()) {
    _init();
  }

  _init() async {}
}
