import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayCubitState> {
  TodayCubit() : super(const TodayCubitState()) {
    _init();
  }

  _init() async {}

  void onDateSelected(DateTime selectedDay) {
    emit(state.copyWith(selectedDate: selectedDay));
  }

  toggleCalendarFormat() {
    emit(state.copyWith(
        calendarFormat:
            state.calendarFormat == CalendarFormatState.month ? CalendarFormatState.week : CalendarFormatState.month));
  }

  todayClick() {
    emit(state.copyWith(selectedDate: DateTime.now()));
  }
}
