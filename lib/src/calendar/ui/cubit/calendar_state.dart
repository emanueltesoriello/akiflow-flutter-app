part of 'calendar_cubit.dart';

class CalendarCubitState extends Equatable {
  final CalendarNavigationState navigationState;
  final CalendarView calendarView;

  const CalendarCubitState({
    this.navigationState = CalendarNavigationState.loading,
    this.calendarView = CalendarView.week,
  });

  CalendarCubitState copyWith({
    CalendarNavigationState? navigationState,
    CalendarView? calendarView,
    bool? calendarChanged,
  }) {
    return CalendarCubitState(
      navigationState: navigationState ?? this.navigationState,
      calendarView: calendarView ?? this.calendarView,
    );
  }

  @override
  List<Object?> get props => [navigationState,calendarView];
}
