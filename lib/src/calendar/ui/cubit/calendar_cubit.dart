import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/utils/calendar_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/calendars_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/models/calendar_view_mode.dart';
import 'package:mobile/src/calendar/ui/models/navigation_state.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/nullable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final CalendarsRepository _calendarsRepository = locator<CalendarsRepository>();
  final SyncCubit _syncCubit;
  final AuthCubit _authCubit;

  final StreamController<PanelState> _panelStateStreamController = StreamController<PanelState>.broadcast();
  Stream<PanelState> get panelStateStream => _panelStateStreamController.stream;

  CalendarCubit(this._syncCubit, this._authCubit) : super(const CalendarCubitState()) {
    _init();
  }

  _init() async {
    fetchFromPreferences();
    fetchCalendars();
    setNonWorkingDays();

    _syncCubit.syncCompletedStream.listen((_) async {
      await fetchCalendars();
    });
  }

  fetchFromPreferences() {
    int calendarViewInt = _preferencesRepository.calendarView;

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

    bool isCalendarThreeDays = _preferencesRepository.isCalendarThreeDays;
    emit(state.copyWith(isCalendarThreeDays: isCalendarThreeDays));

    bool isCalendarWeekendHidden = _preferencesRepository.isCalendarWeekendHidden;
    emit(state.copyWith(isCalendarWeekendHidden: isCalendarWeekendHidden));

    bool areDeclinedEventsHidden = _preferencesRepository.areDeclinedEventsHidden;
    emit(state.copyWith(areDeclinedEventsHidden: areDeclinedEventsHidden));

    bool areCalendarTasksHidden = _preferencesRepository.areCalendarTasksHidden;
    emit(state.copyWith(areCalendarTasksHidden: areCalendarTasksHidden));

    bool groupOverlappingTasks = _preferencesRepository.groupOverlappingTasks;
    emit(state.copyWith(groupOverlappingTasks: groupOverlappingTasks));
  }

  void changeCalendarView(CalendarView calendarView) {
    emit(state.copyWith(calendarView: calendarView));
    String? trackView;

    switch (calendarView) {
      case CalendarView.schedule:
        _preferencesRepository.setCalendarView(CalendarViewMode.agenda);
        trackView = 'agenda';
        break;
      case CalendarView.day:
        _preferencesRepository.setCalendarView(CalendarViewMode.day);
        trackView = 'day';
        break;
      case CalendarView.workWeek:
        _preferencesRepository.setCalendarView(CalendarViewMode.workWeek);
        trackView = 'week';
        break;
      case CalendarView.week:
        _preferencesRepository.setCalendarView(CalendarViewMode.week);
        trackView = 'week';
        break;
      case CalendarView.month:
        _preferencesRepository.setCalendarView(CalendarViewMode.month);
        trackView = 'month';
        break;
      default:
    }
    AnalyticsService.track("Changed calendar view", properties: {
      "mobile": true,
      "calendarView": state.isCalendarThreeDays ? "3-custom" : trackView,
    });
  }

  void setCalendarViewThreeDays(bool isCalendarThreeDays) {
    emit(state.copyWith(isCalendarThreeDays: isCalendarThreeDays));
    _preferencesRepository.setIsCalendarThreeDays(isCalendarThreeDays);
  }

  void setCalendarWeekendHidden(bool isCalendarWeekendHidden) {
    emit(state.copyWith(isCalendarWeekendHidden: isCalendarWeekendHidden));
    _preferencesRepository.setIsCalendarWeekendHidden(isCalendarWeekendHidden);
  }

  void setDeclinedEventsHidden(bool areDeclinedEventsHidden) {
    emit(state.copyWith(areDeclinedEventsHidden: areDeclinedEventsHidden));
    _preferencesRepository.setAreDeclinedEventsHidden(areDeclinedEventsHidden);
  }

  void setCalendarTasksHidden(bool areCalendarTasksHidden) {
    emit(state.copyWith(areCalendarTasksHidden: areCalendarTasksHidden));
    _preferencesRepository.setAreCalendarTasksHidden(areCalendarTasksHidden);
  }

  void setGroupOverlappingTasks(bool groupOverlappingTasks) {
    emit(state.copyWith(groupOverlappingTasks: groupOverlappingTasks));
    _preferencesRepository.setGroupOverlappingTasks(groupOverlappingTasks);
  }

  void setNonWorkingDays() {
    emit(state.copyWith(nonWorkingDays: computeNonWorkinkDays()));
  }

  void setAppointmentTapped(bool tapped) {
    emit(state.copyWith(appointmentTapped: tapped));
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
    if (calendar.settings["visibleMobile"] != null) {
      AnalyticsService.track(calendar.settings["visibleMobile"] ? "Calendar shown" : "Calendar hidden", properties: {
        "mobile": true,
        "mode": "click",
        "origin": "calendar",
      });
    }
  }

  void setVisibleDates(List<DateTime> visibleDates) {
    emit(state.copyWith(visibleDates: visibleDates));
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

  Calendar changeCalendarVisibility(Calendar calendar) {
    dynamic settings = calendar.settings;
    if (settings != null) {
      bool isVisible = calendar.settings["visibleMobile"] ?? calendar.settings["visible"] ?? false;

      settings["visibleMobile"] = !isVisible;
      settings["visibleMobile"]
          ? settings["notificationsEnabledMobile"] = true
          : settings["notificationsEnabledMobile"] = false;
    } else {
      settings = {
        "visible": true,
        "notificationsEnabled": true,
        "visibleMobile": true,
        "notificationsEnabledMobile": true
      };
    }

    calendar = calendar.copyWith(settings: settings, updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));

    return calendar;
  }

  Calendar changeCalendarNotifications(Calendar calendar) {
    dynamic settings = calendar.settings;
    if (settings != null) {
      bool isEnabled =
          calendar.settings["notificationsEnabledMobile"] ?? calendar.settings["notificationsEnabled"] ?? false;

      settings["notificationsEnabledMobile"] = !isEnabled;
    } else {
      settings = {
        "visible": true,
        "notificationsEnabled": true,
        "visibleMobile": true,
        "notificationsEnabledMobile": true
      };
    }

    calendar = calendar.copyWith(settings: settings, updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));

    return calendar;
  }

  List<int> computeNonWorkinkDays() {
    int firstWorkdayOfWeek = DateTime.monday;
    if (_authCubit.state.user?.settings?["calendar"] != null &&
        _authCubit.state.user?.settings?["calendar"]["firstWorkingDayOfWeek"] != null) {
      var firstWorkdayFromDb = _authCubit.state.user?.settings?["calendar"]["firstWorkingDayOfWeek"];
      if (firstWorkdayFromDb is String) {
        firstWorkdayOfWeek = int.parse(firstWorkdayFromDb);
      } else if (firstWorkdayFromDb is int) {
        firstWorkdayOfWeek = firstWorkdayFromDb;
      }
    }
    return CalendarUtils.getNonWorkingDays(firstWorkdayOfWeek);
  }
}
