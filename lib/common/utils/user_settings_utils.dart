class UserSettingsUtils {
  static String generalSection = 'general';
  static String calendarSection = 'calendar';
  static String tasksSection = 'tasks';
  static List<String> sections = [generalSection, calendarSection, tasksSection];

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
        print('UserSettingsUtils - remote null ${remoteSetting['key']}');
        mergedSectionSettings.add(localSetting);
      } else if (localSetting['updatedAt'] == null && remoteSetting['updatedAt'] != null) {
        print('UserSettingsUtils - local null ${remoteSetting['key']}');
        mergedSectionSettings.add(remoteSetting);
      } else if (remoteSetting['updatedAt'] != null && localSetting['updatedAt'] != null) {
        if (remoteSetting['updatedAt'] > localSetting['updatedAt']) {
          print('UserSettingsUtils - remote > local ${remoteSetting['key']}');
          mergedSectionSettings.add(remoteSetting);
        } else if (localSetting['updatedAt'] > remoteSetting['updatedAt']) {
          print('UserSettingsUtils - local > remote ${remoteSetting['key']}');
          mergedSectionSettings.add(localSetting);
        } else {
          print('UserSettingsUtils - remote =? local ${remoteSetting['key']}');
          mergedSectionSettings.add(remoteSetting);
        }
      } else if (remoteSetting['updatedAt'] == null && localSetting['updatedAt'] == null) {
        print('UserSettingsUtils - both null ${remoteSetting['key']}');
        mergedSectionSettings.add(remoteSetting);
      }
    }
    return mergedSectionSettings;
  }

  static List<dynamic> updateSectionSetting(
      {required String sectionName,
      required List<dynamic> localSectionSettings,
      required Map<String, dynamic> newSetting}) {
    List<dynamic> newSectionSettings = [];
    bool settingFound = false;

    for (Map<String, dynamic> oldSetting in localSectionSettings) {
      if (oldSetting['key'] == newSetting['key']) {
        print('HIDE WEEKEND setting found $newSetting');
        newSectionSettings.add(newSetting);
        settingFound = true;
      } else {
        newSectionSettings.add(oldSetting);
      }
    }
    if (!settingFound) {
      print('HIDE WEEKEND setting NOT found $newSetting');
      newSectionSettings.add(newSetting);
    }
    return newSectionSettings;
  }
}
