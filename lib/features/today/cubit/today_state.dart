part of 'today_cubit.dart';

enum CalendarFormatState {
  month,
  week,
}

class TodayCubitState extends Equatable {
  final bool loading;
  final DateTime? selectedDate;
  final CalendarFormatState calendarFormat;

  const TodayCubitState({
    this.loading = false,
    this.selectedDate,
    this.calendarFormat = CalendarFormatState.week,
  });

  TodayCubitState copyWith({
    bool? loading,
    DateTime? selectedDate,
    CalendarFormatState? calendarFormat,
  }) {
    return TodayCubitState(
      loading: loading ?? this.loading,
      selectedDate: selectedDate ?? this.selectedDate,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }

  @override
  List<Object?> get props => [loading, selectedDate, calendarFormat];
}
