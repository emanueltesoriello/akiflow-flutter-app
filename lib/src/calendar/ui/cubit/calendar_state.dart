part of 'calendar_cubit.dart';

class CalendarCubitState extends Equatable {
  final CalendarNavigationState navigationState;
  final CalendarView calendarView;
  final bool isCalendarThreeDays;
  final bool isCalendarWeekendHidden;
  final List<Calendar> calendars;
  final List<DateTime> visibleDates;
  //final DateTime selectedPanelDate;
  final PanelState panelState;

  const CalendarCubitState({
    this.navigationState = CalendarNavigationState.loading,
    this.calendarView = CalendarView.week,
    this.isCalendarThreeDays = false,
    this.isCalendarWeekendHidden = false,
    this.calendars = const [],
    this.visibleDates = const [],
    //required this.selectedPanelDate,
    this.panelState = PanelState.closed,
  });

  CalendarCubitState copyWith({
    CalendarNavigationState? navigationState,
    CalendarView? calendarView,
    bool? isCalendarThreeDays,
    bool? isCalendarWeekendHidden,
    List<Calendar>? calendars,
    List<DateTime>? visibleDates,
    //DateTime? selectedPanelDate,
    PanelState? panelState,
  }) {
    return CalendarCubitState(
      navigationState: navigationState ?? this.navigationState,
      calendarView: calendarView ?? this.calendarView,
      isCalendarThreeDays: isCalendarThreeDays ?? this.isCalendarThreeDays,
      isCalendarWeekendHidden: isCalendarWeekendHidden ?? this.isCalendarWeekendHidden,
      calendars: calendars ?? this.calendars,
      visibleDates: visibleDates ?? this.visibleDates,
      //selectedPanelDate: selectedPanelDate ?? this.selectedPanelDate,
      panelState: panelState ?? this.panelState,
    );
  }

  @override
  List<Object?> get props => [
        navigationState,
        calendarView,
        isCalendarThreeDays,
        isCalendarWeekendHidden,
        calendars,
        visibleDates,
       // selectedPanelDate,
        panelState,
      ];
}
