import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/utils/calendar_utils.dart';
import 'package:mobile/common/utils/user_settings_utils.dart';
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
import 'package:syncfusion_calendar/calendar.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarCubitState> {
  final CalendarsRepository _calendarsRepository = locator<CalendarsRepository>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final SyncCubit _syncCubit;
  final AuthCubit _authCubit;

  final StreamController<PanelState> _panelStateStreamController = StreamController<PanelState>.broadcast();
  Stream<PanelState> get panelStateStream => _panelStateStreamController.stream;

  CalendarCubit(this._syncCubit, this._authCubit) : super(const CalendarCubitState()) {
    _init();
  }

  _init() async {
    try {
      fetchFromPreferences();
    } catch (e) {
      print('ERROR calendar_cubit fetchFromPreferences: $e');
    }

    fetchCalendars();
    setNonWorkingDays();
    await setSystemStartOfWeekDay();

    _syncCubit.syncCompletedStream.listen((_) async {
      await fetchCalendars();
    });
  }

  fetchFromPreferences() {
    dynamic viewMobile = _authCubit.getSettingBySectionAndKey(
        sectionName: UserSettingsUtils.calendarSection, key: UserSettingsUtils.view);

    dynamic isCalendarWeekendHidden = _authCubit.getSettingBySectionAndKey(
        sectionName: UserSettingsUtils.calendarSection, key: UserSettingsUtils.hideWeekends);
    emit(state.copyWith(isCalendarWeekendHidden: isCalendarWeekendHidden ?? false));

    switch (viewMobile) {
      case CalendarViewMode.agenda:
        emit(state.copyWith(calendarView: CalendarView.schedule));
        break;
      case CalendarViewMode.day:
        emit(state.copyWith(calendarView: CalendarView.day));
        break;
      case CalendarViewMode.threeDays:
        emit(state.copyWith(calendarView: state.isCalendarWeekendHidden ? CalendarView.workWeek : CalendarView.week));
        break;
      case CalendarViewMode.workWeek:
        emit(state.copyWith(calendarView: CalendarView.workWeek));
        break;
      case CalendarViewMode.week:
        emit(state.copyWith(calendarView: state.isCalendarWeekendHidden ? CalendarView.workWeek : CalendarView.week));
        break;
      case CalendarViewMode.month:
        emit(state.copyWith(calendarView: CalendarView.month));
        break;
      default:
        emit(state.copyWith(calendarView: CalendarView.day));
    }

    dynamic view = _authCubit.getSettingBySectionAndKey(
        sectionName: UserSettingsUtils.calendarSection, key: UserSettingsUtils.view);
    emit(state.copyWith(isCalendarThreeDays: view != null ? view == UserSettingsUtils.threeCustom : false));

    dynamic areDeclinedEventsHidden = _authCubit.getSettingBySectionAndKey(
        sectionName: UserSettingsUtils.calendarSection, key: UserSettingsUtils.declinedEventsVisible);
    emit(state.copyWith(areDeclinedEventsHidden: areDeclinedEventsHidden ?? false));

    dynamic areCalendarTasksHidden = _authCubit.getSettingBySectionAndKey(
        sectionName: UserSettingsUtils.calendarSection, key: UserSettingsUtils.calendarTasksHidden);
    emit(state.copyWith(areCalendarTasksHidden: areCalendarTasksHidden ?? false));

    dynamic groupOverlappingTasks = _authCubit.getSettingBySectionAndKey(
        sectionName: UserSettingsUtils.calendarSection, key: UserSettingsUtils.groupCloseTasks);
    emit(state.copyWith(groupOverlappingTasks: groupOverlappingTasks ?? true));
  }

  void changeCalendarView(CalendarView calendarView) {
    emit(state.copyWith(calendarView: calendarView));
    String? trackView;

    switch (calendarView) {
      case CalendarView.schedule:
        trackView = 'agenda';
        break;
      case CalendarView.day:
        trackView = 'day';
        break;
      case CalendarView.workWeek:
        trackView = 'workWeek';
        break;
      case CalendarView.week:
        trackView = 'week';
        break;
      case CalendarView.month:
        trackView = 'month';
        break;
      default:
    }

    saveNewSetting(sectionName: UserSettingsUtils.calendarSection, key: UserSettingsUtils.view, value: trackView);

    AnalyticsService.track("Changed calendar view", properties: {
      "mobile": true,
      "calendarView": state.isCalendarThreeDays ? "3-custom" : trackView,
    });
  }

  void setCalendarViewThreeDays(bool isCalendarThreeDays) {
    emit(state.copyWith(isCalendarThreeDays: isCalendarThreeDays));

    if (isCalendarThreeDays) {
      saveNewSetting(
          sectionName: UserSettingsUtils.calendarSection,
          key: UserSettingsUtils.view,
          value: UserSettingsUtils.threeCustom);
    }
  }

  void setCalendarWeekendHidden(bool isCalendarWeekendHidden) {
    emit(state.copyWith(isCalendarWeekendHidden: isCalendarWeekendHidden));

    saveNewSetting(
        sectionName: UserSettingsUtils.calendarSection,
        key: UserSettingsUtils.hideWeekends,
        value: isCalendarWeekendHidden);
  }

  void setDeclinedEventsHidden(bool areDeclinedEventsHidden) {
    emit(state.copyWith(areDeclinedEventsHidden: areDeclinedEventsHidden));

    saveNewSetting(
        sectionName: UserSettingsUtils.calendarSection,
        key: UserSettingsUtils.declinedEventsVisible,
        value: areDeclinedEventsHidden);
  }

  void setCalendarTasksHidden(bool areCalendarTasksHidden) {
    emit(state.copyWith(areCalendarTasksHidden: areCalendarTasksHidden));

    saveNewSetting(
        sectionName: UserSettingsUtils.calendarSection,
        key: UserSettingsUtils.calendarTasksHidden,
        value: areCalendarTasksHidden);
  }

  void setGroupOverlappingTasks(bool groupOverlappingTasks) {
    emit(state.copyWith(groupOverlappingTasks: groupOverlappingTasks));

    saveNewSetting(
        sectionName: UserSettingsUtils.calendarSection,
        key: UserSettingsUtils.groupCloseTasks,
        value: groupOverlappingTasks);
  }

  void setNonWorkingDays() {
    emit(state.copyWith(nonWorkingDays: computeNonWorkinkDays()));
  }

  Future<void> setSystemStartOfWeekDay() async {
    int systemDefault = DateTime.sunday;
    systemDefault =
        1; //await CalendarUtils.retrieveSystemFirstDayOfWeek(); -> todo fix this method in order to work into isolates
    emit(state.copyWith(systemStartOfWeekDay: systemDefault));
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
    if (_authCubit.state.user?.settings?["calendar"] != null) {
      List<dynamic> calendarSettings = _authCubit.state.user?.settings?["calendar"];
      for (Map<String, dynamic> element in calendarSettings) {
        if (element['key'] == 'firstWorkingDayOfWeek') {
          var firstDayFromDb = element['value'];
          if (firstDayFromDb != null) {
            if (firstDayFromDb is String) {
              firstWorkdayOfWeek = int.parse(firstDayFromDb);
            } else if (firstDayFromDb is int) {
              firstWorkdayOfWeek = firstDayFromDb;
            }
          }
        }
      }
    }
    return CalendarUtils.getNonWorkingDays(firstWorkdayOfWeek);
  }

  void saveNewSetting({required String sectionName, required String key, required dynamic value}) {
    Map<String, dynamic> setting = {
      'key': key,
      'value': value,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
    List<dynamic> sectionSettings = UserSettingsUtils.updateSectionSetting(
        sectionName: sectionName,
        localSectionSettings: _preferencesRepository.user?.settings?[sectionName],
        newSetting: setting);

    _authCubit.updateSection(sectionName: sectionName, section: sectionSettings);

    _authCubit.updateUserSettings({
      sectionName: [setting]
    });
  }
}
