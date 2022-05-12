import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayCubitState> {
  final TasksCubit tasksCubit;

  TodayCubit(this.tasksCubit) : super(TodayCubitState(selectedDate: DateTime.now()));

  void onDateSelected(DateTime selectedDay) {
    emit(state.copyWith(selectedDate: selectedDay));
    tasksCubit.getTodayTasksByDate(selectedDay);
  }

  toggleCalendarFormat() {
    emit(state.copyWith(
        calendarFormat:
            state.calendarFormat == CalendarFormatState.month ? CalendarFormatState.week : CalendarFormatState.month));
  }

  todayClick() {
    emit(state.copyWith(selectedDate: DateTime.now()));
    tasksCubit.getTodayTasksByDate(DateTime.now());
  }

  void openTodoList() {
    emit(state.copyWith(todosListOpen: !state.todosListOpen));
  }

  void openPinnedList() {
    emit(state.copyWith(pinnedListOpen: !state.pinnedListOpen));
  }

  void openCompletedList() {
    emit(state.copyWith(completedListOpen: !state.completedListOpen));
  }
}
