import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

part 'today_state.dart';

class TodayCubit extends Cubit<TodayCubitState> {
  late final TasksCubit tasksCubit;

  TodayCubit() : super(TodayCubitState(selectedDate: DateTime.now()));

  final StreamController<PanelState> _panelStateStreamController = StreamController<PanelState>.broadcast();
  Stream<PanelState> get panelStateStream => _panelStateStreamController.stream;

  void attachTasksCubit(TasksCubit tasksCubit) {
    this.tasksCubit = tasksCubit;
  }

  void onDateSelected(DateTime selectedDay) {
    emit(state.copyWith(selectedDate: selectedDay, calendarFormat: CalendarFormatState.week));
    tasksCubit.getTodayTasksByDate(selectedDay);
    _panelStateStreamController.add(PanelState.closed);
  }

  tapAppBarTextDate() {
    PanelState current = state.panelState;

    if (current == PanelState.closed) {
      _panelStateStreamController.add(PanelState.opened);
    } else {
      _panelStateStreamController.add(PanelState.closed);
    }
  }

  todayClick() {
    emit(state.copyWith(selectedDate: DateTime.now(), calendarFormat: CalendarFormatState.week));
    tasksCubit.getTodayTasksByDate(DateTime.now());
    _panelStateStreamController.add(PanelState.closed);
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

  void panelClosed() {
    emit(state.copyWith(panelState: PanelState.closed));
  }

  void panelOpened() {
    emit(state.copyWith(panelState: PanelState.opened));
  }
}
