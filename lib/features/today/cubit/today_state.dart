part of 'today_cubit.dart';

enum CalendarFormatState {
  month,
  week,
}

class TodayCubitState extends Equatable {
  final bool loading;
  final DateTime selectedDate;
  final CalendarFormatState calendarFormat;
  final bool todosListOpen;
  final bool pinnedListOpen;
  final bool completedListOpen;

  const TodayCubitState({
    this.loading = false,
    required this.selectedDate,
    this.calendarFormat = CalendarFormatState.week,
    this.todosListOpen = true,
    this.pinnedListOpen = true,
    this.completedListOpen = false,
  });

  TodayCubitState copyWith({
    bool? loading,
    DateTime? selectedDate,
    CalendarFormatState? calendarFormat,
    bool? todosListOpen,
    bool? pinnedListOpen,
    bool? completedListOpen,
  }) {
    return TodayCubitState(
      loading: loading ?? this.loading,
      selectedDate: selectedDate ?? this.selectedDate,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      todosListOpen: todosListOpen ?? this.todosListOpen,
      pinnedListOpen: pinnedListOpen ?? this.pinnedListOpen,
      completedListOpen: completedListOpen ?? this.completedListOpen,
    );
  }

  @override
  List<Object?> get props => [loading, selectedDate, calendarFormat, todosListOpen, pinnedListOpen, completedListOpen];
}
