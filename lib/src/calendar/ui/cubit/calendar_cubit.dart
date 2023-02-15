import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/calendars_repository.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/models/calendar_view_mode.dart';
import 'package:mobile/src/calendar/ui/models/navigation_state.dart';
import 'package:models/calendar/calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final CalendarsRepository _calendarsRepository = locator<CalendarsRepository>();
  final SyncCubit _syncCubit;

  final StreamController<PanelState> _panelStateStreamController = StreamController<PanelState>.broadcast();
  Stream<PanelState> get panelStateStream => _panelStateStreamController.stream;

  CalendarCubit(this._syncCubit) : super(CalendarCubitState(selectedPanelDate: DateTime.now())) {
    _init();
  }

  _init() async {
    fetchFromPreferences();
    fetchCalendars();

    _syncCubit.syncCompletedStream.listen((_) async {
      await fetchCalendars();
    });
  }

  fetchFromPreferences() {
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

  Future<void> fetchCalendars() async {
    List<Calendar> calendars = await _calendarsRepository.getCalendars();
    calendars.sort((a, b) => b.primary ?? false ? 1 : -1);
    calendars.sort((a, b) => b.akiflowPrimary ?? false ? 1 : -1);
    emit(state.copyWith(calendars: calendars));
  }

  Future<void> updateCalendar(Calendar calendar) async {
    await _calendarsRepository.updateById(calendar.id, data: calendar);

    await fetchCalendars();

    _syncCubit.sync(entities: [Entity.calendars, Entity.events]);
  }

  void setVisibleDates(List<DateTime> visibleDates) {
    emit(state.copyWith(visibleDates: visibleDates));
  }

  void onPanelDateSelected(DateTime selectedDay) {
    emit(state.copyWith(selectedPanelDate: selectedDay));
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

  void closePanel() {
    _panelStateStreamController.add(PanelState.closed);
  }

  void panelClosed() {
    emit(state.copyWith(panelState: PanelState.closed));
  }

  void panelOpened() {
    emit(state.copyWith(panelState: PanelState.opened));
  }
}
