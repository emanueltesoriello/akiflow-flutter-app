import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/src/calendar/ui/models/calendar_view_mode.dart';
import 'package:mobile/src/calendar/ui/models/navigation_state.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  CalendarCubit() : super(const CalendarCubitState()) {
    _init();
  }

  _init() async {
    int calendarViewInt = _preferencesRepository.calendarView;
    bool isCalendarThreeDays = _preferencesRepository.isCalendarThreeDays;
    bool isCalendarWeekendHidden = _preferencesRepository.isCalendarWeekendHidden;

    switch (calendarViewInt) {
      case CalendarViewMode.agenda:
        emit(state.copyWith(calendarView: CalendarView.schedule));
        break;
      case CalendarViewMode.day:
        emit(state.copyWith(calendarView: CalendarView.day));
        break;
      case CalendarViewMode.workWeek:
        emit(state.copyWith(calendarView: CalendarView.workWeek));
        break;
      case CalendarViewMode.week:
        emit(state.copyWith(calendarView: CalendarView.week));
        break;
      case CalendarViewMode.month:
        emit(state.copyWith(calendarView: CalendarView.month));
        break;
      default:
    }

    if (isCalendarThreeDays) {
      emit(state.copyWith(isCalendarThreeDays: isCalendarThreeDays));
    }

    if (isCalendarWeekendHidden) {
      emit(state.copyWith(isCalendarWeekendHidden: isCalendarWeekendHidden));
    }
  }

  void changeCalendarView(CalendarView calendarView) {
    emit(state.copyWith(calendarView: calendarView));

    switch (calendarView) {
      case CalendarView.schedule:
        _preferencesRepository.setCalendarView(CalendarViewMode.agenda);
        break;
      case CalendarView.day:
        _preferencesRepository.setCalendarView(CalendarViewMode.day);
        break;
      case CalendarView.workWeek:
        _preferencesRepository.setCalendarView(CalendarViewMode.workWeek);
        break;
      case CalendarView.week:
        _preferencesRepository.setCalendarView(CalendarViewMode.week);
        break;
      case CalendarView.month:
        _preferencesRepository.setCalendarView(CalendarViewMode.month);
        break;
      default:
    }
  }

  void setCalendarViewThreeDays(bool isCalendarThreeDays) {
    emit(state.copyWith(isCalendarThreeDays: isCalendarThreeDays));
    _preferencesRepository.setIsCalendarThreeDays(isCalendarThreeDays);
  }

  void setCalendarWeekendHidden(bool isCalendarWeekendHidden) {
    emit(state.copyWith(isCalendarWeekendHidden: isCalendarWeekendHidden));
    _preferencesRepository.setIsCalendarWeekendHidden(isCalendarWeekendHidden);
  }

  //N.B. When we need to get access to the state of other BlocProviders we can get access to them declaring streams that listen their states.
}
