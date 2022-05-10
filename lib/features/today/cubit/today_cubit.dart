import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayCubitState> {
  TodayCubit() : super(TodayCubitState(selectedDate: DateTime.now())) {
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

  void openTodoList() {
    emit(state.copyWith(todosListOpen: true));
  }

  void openPinnedList() {
    emit(state.copyWith(pinnedListOpen: true));
  }

  void openCompletedList() {
    emit(state.copyWith(completedListOpen: true));
  }
}
