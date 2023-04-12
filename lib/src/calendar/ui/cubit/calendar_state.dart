part of 'calendar_cubit.dart';

class CalendarCubitState extends Equatable {
  final CalendarNavigationState navigationState;
  final CalendarView calendarView;
  final bool isCalendarThreeDays;
  final bool isCalendarWeekendHidden;
  final bool areDeclinedEventsHidden;
  final bool areCalendarTasksHidden;
  final bool groupOverlappingTasks;
  final List<Calendar> calendars;
  final List<DateTime> visibleDates;
  final PanelState panelState;

  const CalendarCubitState({
    this.navigationState = CalendarNavigationState.loading,
    this.calendarView = CalendarView.week,
    this.isCalendarThreeDays = false,
    this.isCalendarWeekendHidden = false,
    this.areDeclinedEventsHidden = false,
    this.areCalendarTasksHidden = false,
    this.groupOverlappingTasks = false,
    this.calendars = const [],
    this.visibleDates = const [],
    this.panelState = PanelState.closed,
  });

  CalendarCubitState copyWith({
    CalendarNavigationState? navigationState,
    CalendarView? calendarView,
    bool? isCalendarThreeDays,
    bool? isCalendarWeekendHidden,
    bool? areDeclinedEventsHidden,
    bool? areCalendarTasksHidden,
    bool? groupOverlappingTasks,
    List<Calendar>? calendars,
    List<DateTime>? visibleDates,
    PanelState? panelState,
  }) {
    return CalendarCubitState(
      navigationState: navigationState ?? this.navigationState,
      calendarView: calendarView ?? this.calendarView,
      isCalendarThreeDays: isCalendarThreeDays ?? this.isCalendarThreeDays,
      isCalendarWeekendHidden: isCalendarWeekendHidden ?? this.isCalendarWeekendHidden,
      areDeclinedEventsHidden: areDeclinedEventsHidden ?? this.areDeclinedEventsHidden,
      areCalendarTasksHidden: areCalendarTasksHidden ?? this.areCalendarTasksHidden,
      groupOverlappingTasks: groupOverlappingTasks ?? this.groupOverlappingTasks,
      calendars: calendars ?? this.calendars,
      visibleDates: visibleDates ?? this.visibleDates,
      panelState: panelState ?? this.panelState,
    );
  }

  @override
  List<Object?> get props => [
        navigationState,
        calendarView,
        isCalendarThreeDays,
        isCalendarWeekendHidden,
        areDeclinedEventsHidden,
        areCalendarTasksHidden,
        groupOverlappingTasks,
        calendars,
        visibleDates,
        panelState,
      ];
}
