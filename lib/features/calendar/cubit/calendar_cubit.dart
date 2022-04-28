import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarCubitState> {
  CalendarCubit() : super(const CalendarCubitState()) {
    _init();
  }

  _init() async {}
}
