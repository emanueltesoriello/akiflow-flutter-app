part of 'calendar_cubit.dart';

class CalendarCubitState extends Equatable {
  final CalendarNavigationState navigationState;
  final CalendarView calendarView;
  final bool isCalendarThreeDays;
  final bool isCalendarWeekendHidden;

  const CalendarCubitState({
    this.navigationState = CalendarNavigationState.loading,
    this.calendarView = CalendarView.week,
    this.isCalendarThreeDays = false,
    this.isCalendarWeekendHidden = false,
  });

  CalendarCubitState copyWith({
    CalendarNavigationState? navigationState,
    CalendarView? calendarView,
    bool? isCalendarThreeDays,
    bool? isCalendarWeekendHidden,
  }) {
    return CalendarCubitState(
        navigationState: navigationState ?? this.navigationState,
        calendarView: calendarView ?? this.calendarView,
        isCalendarThreeDays: isCalendarThreeDays ?? this.isCalendarThreeDays,
        isCalendarWeekendHidden: isCalendarWeekendHidden ?? this.isCalendarWeekendHidden);
  }

  @override
  List<Object?> get props => [navigationState, calendarView, isCalendarThreeDays, isCalendarWeekendHidden];
}
