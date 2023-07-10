import 'package:mobile/core/preferences.dart';

class UserSettingsUtils {
  static String generalSection = 'general';
  static String calendarSection = 'calendar';
  static String tasksSection = 'tasks';
  static String notificationsSection = 'notifications';
  static List<String> sections = [generalSection, calendarSection, tasksSection, notificationsSection];

  static String view = 'view_mobile';
  static String threeCustom = '3-custom';
  static String hideWeekends = 'hideWeekends_mobile';
  static String declinedEventsVisible = 'declinedEventsVisible_mobile';
  static String calendarTasksHidden = 'calendarTasksHidden_mobile';
  static String groupCloseTasks = 'groupCloseTasks_mobile';
  static String timeFormat = 'timeFormat_mobile';

  static String eventsNotificationsEnabled = 'eventsNotificationsEnabled_mobile';
  static String eventsNotificationsTime = 'eventsNotificationsTime_mobile';
  static String tasksNotificationsEnabled = 'tasksNotificationsEnabled_mobile';
  static String tasksNotificationsTime = 'tasksNotificationsTime_mobile';
  static String dailyOverviewNotificationsEnabled = 'dailyOverviewNotificationsEnabled_mobile';
  static String dailyOverviewNotificationsTime = 'dailyOverviewNotificationsTime_mobile';
  static String taskCompletedSoundEnabled = 'taskCompletedSoundEnabled_mobile';

  static Map<String, dynamic>? compareRemoteWithLocal({
    required Map<String, dynamic>? remoteSettings,
    required Map<String, dynamic>? localSettings,
  }) {
    Map<String, dynamic>? mergedSettings = remoteSettings;

    for (String section in sections) {
      List<dynamic> remoteSectionSettings = remoteSettings?[section];
      List<dynamic> localSectionSettings = localSettings?[section];

      List<dynamic> mergedSectionSettings = doComparisonForSection(
          remoteSectionSettings: remoteSectionSettings, localSectionSettings: localSectionSettings);

      mergedSettings?[section] = mergedSectionSettings;
    }
    return mergedSettings;
  }

  static List<dynamic> doComparisonForSection({
    required List<dynamic> remoteSectionSettings,
    required List<dynamic> localSectionSettings,
  }) {
    List<dynamic> mergedSectionSettings = [];

    for (Map<String, dynamic> localSetting in localSectionSettings) {
      Map<String, dynamic> remoteSetting = localSectionSettings.firstWhere(
        (setting) => setting['key'] == localSetting['key'],
        orElse: () {
          mergedSectionSettings.add(localSetting);
        },
      );
      if (remoteSetting['updatedAt'] == null && localSetting['updatedAt'] != null) {
        mergedSectionSettings.add(localSetting);
      } else if (localSetting['updatedAt'] == null && remoteSetting['updatedAt'] != null) {
        mergedSectionSettings.add(remoteSetting);
      } else if (remoteSetting['updatedAt'] != null && localSetting['updatedAt'] != null) {
        if (remoteSetting['updatedAt'] > localSetting['updatedAt']) {
          mergedSectionSettings.add(remoteSetting);
        } else if (localSetting['updatedAt'] > remoteSetting['updatedAt']) {
          mergedSectionSettings.add(localSetting);
        } else {
          mergedSectionSettings.add(remoteSetting);
        }
      } else if (remoteSetting['updatedAt'] == null && localSetting['updatedAt'] == null) {
        mergedSectionSettings.add(remoteSetting);
      }
    }
    return mergedSectionSettings;
  }

  static dynamic getSettingBySectionAndKey(
      {required PreferencesRepository preferencesRepository, required String sectionName, required String key}) {
    Map<String, dynamic>? settings = preferencesRepository.user?.settings;
    List<dynamic>? section = settings?[sectionName];

    String desktopVersionKey = key.split('_').first;
    bool settingFound = false;

    if (section != null) {
      for (Map<String, dynamic> element in section) {
        if (element['key'] == key) {
          settingFound = true;
          return element['value'];
        }
      }
      if (!settingFound && desktopVersionKey != 'view') {
        for (Map<String, dynamic> element in section) {
          if (element['key'] == desktopVersionKey) {
            return element['value'];
          }
        }
      }
    }
  }

  static List<dynamic> updateSectionSetting(
      {required String sectionName,
      required List<dynamic> localSectionSettings,
      required Map<String, dynamic> newSetting}) {
    List<dynamic> newSectionSettings = [];
    bool settingFound = false;

    for (Map<String, dynamic> oldSetting in localSectionSettings) {
      if (oldSetting['key'] == newSetting['key']) {
        newSectionSettings.add(newSetting);
        settingFound = true;
      } else {
        newSectionSettings.add(oldSetting);
      }
    }
    if (!settingFound) {
      newSectionSettings.add(newSetting);
    }
    return newSectionSettings;
  }
}
