import 'dart:convert';

import 'package:models/account/account_token.dart';
import 'package:models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract class PreferencesRepository {
  Future<void> clear();

  Future<void> saveUser(User user);

  User? get user;

  bool get userSettingsAreV4;
  Future<void> setUserSettingsAreV4(bool value);

  bool get inboxNoticeHidden;
  Future<void> setInboxNoticeHidden(bool value);

  DateTime? get lastAccountsSyncAt;
  Future<void> setLastAccountsSyncAt(DateTime? value);

  DateTime? get lastCalendarsSyncAt;
  Future<void> setLastCalendarsSyncAt(DateTime? value);

  DateTime? get lastTasksSyncAt;
  Future<void> setLastTasksSyncAt(DateTime? value);

  DateTime? get lastLabelsSyncAt;

  DateTime? get lastAppUseAt;

  Future<void> setLastAppUseAt(DateTime? value);

  Future<void> setLastLabelsSyncAt(DateTime? value);

  DateTime? get lastEventsSyncAt;
  Future<void> setLastEventsSyncAt(DateTime? value);

  DateTime? get lastEventModifiersSyncAt;
  Future<void> setLastEventModifiersSyncAt(DateTime? value);

  DateTime? get lastContactsSyncAt;
  Future<void> setLastContactsSyncAt(DateTime? value);

  DateTime? get lastDocsSyncAt;
  Future<void> setLastDocsSyncAt(DateTime? value);

  DateTime? lastSyncForAccountId(String accountId);
  Future<void> setLastSyncForAccountId(String accountId, DateTime? value);

  AccountToken? getAccountToken(String accountId);
  Future<void> setAccountToken(String accountId, AccountToken token);
  Future<void> removeAccountToken(String accountId);

  bool get firstTimeLoaded;
  Future<void> setFirstTimeLoaded(bool value);

  bool get onboardingCompleted;
  Future<void> setOnboardingCompleted(bool value);

  bool getV3AccountActive(String accountId);
  Future<void> setV3AccountActive(String accountId, bool active);

  bool get reconnectPageSkipped;
  Future<void> setReconnectPageSkipped(bool value);

  int get timeFormat;
  Future<void> setTimeFormat(int value);

  String get deviceUUID;
  Future<void> setDeviceUUID(String value);

  int get recurringBackgroundSyncCounter;
  Future<void> setRecurringBackgroundSyncCounter(int value);

  int get recurringNotificationsSyncCounter;
  Future<void> setRecurringNotificationsSyncCounter(int value);

  String get getLastSavedTimeZone;
  Future<void> setLastSavedTimeZone(String value);

  DateTime? get lastTaskDoneAt;
  Future<void> setLastTaskDoneAt(DateTime? value);

  DateTime? get lastDayInboxZero;
  Future<void> setLastDayInboxZero(DateTime? value);

  DateTime? get lastDayTodayZero;
  Future<void> setDayTodayZero(DateTime? value);
}

class PreferencesRepositoryImpl implements PreferencesRepository {
  final SharedPreferences _prefs;

  PreferencesRepositoryImpl(this._prefs);

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<void> saveUser(User user) async {
    await _prefs.setString("user", jsonEncode(user.toMap()));
  }

  @override
  User? get user {
    final userString = _prefs.getString("user");

    if (userString == null) {
      return null;
    }

    return User.fromMap(jsonDecode(userString));
  }

  @override
  bool get userSettingsAreV4 {
    return _prefs.getBool("userSettingsAreV4") ?? false;
  }

  @override
  Future<void> setUserSettingsAreV4(bool value) async {
    await _prefs.setBool("userSettingsAreV4", value);
  }

  @override
  bool get inboxNoticeHidden {
    return _prefs.getBool("inboxNoticeHidden") ?? false;
  }

  @override
  bool get availabilitiesNoticeHidden {
    return _prefs.getBool("availabilitiesNoticeHidden") ?? false;
  }

  @override
  Future<void> setInboxNoticeHidden(bool value) async {
    await _prefs.setBool("inboxNoticeHidden", value);
  }

  @override
  Future<void> setAvailabilitiesNoticeHidden(bool value) async {
    await _prefs.setBool("availabilitiesNoticeHidden", value);
  }

  @override
  DateTime? get lastAccountsV3SyncAt {
    String? value = _prefs.getString("lastAccountsV3SyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastAccountsV3SyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastAccountsV3SyncAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastAccountsSyncAt {
    String? value = _prefs.getString("lastAccountsSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastAccountsSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastAccountsSyncAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastCalendarsSyncAt {
    String? value = _prefs.getString("lastCalendarsSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastCalendarsSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastCalendarsSyncAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastTasksSyncAt {
    String? value = _prefs.getString("lastTasksSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastTasksSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastTasksSyncAt", value.toIso8601String());
    }
  }

  @override
  Future<void> setLastAppUseAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastAppUseAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastAppUseAt {
    String? value = _prefs.getString("lastAppUseAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  DateTime? get lastLabelsSyncAt {
    String? value = _prefs.getString("lastLabelsSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastLabelsSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastLabelsSyncAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastEventsSyncAt {
    String? value = _prefs.getString("lastEventsSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastEventsSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastEventsSyncAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastEventModifiersSyncAt {
    String? value = _prefs.getString("lastEventModifiersSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastEventModifiersSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastEventModifiersSyncAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastContactsSyncAt {
    String? value = _prefs.getString("lastContactsSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastContactsSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastContactsSyncAt", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastDocsSyncAt {
    String? value = _prefs.getString("lastDocsSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastDocsSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastDocsSyncAt", value.toIso8601String());
    }
  }

  @override
  AccountToken? getAccountToken(String accountId) {
    String? tokenString = _prefs.getString("integration_$accountId");

    if (tokenString == null) {
      return null;
    }

    return AccountToken.fromMap(jsonDecode(tokenString));
  }

  @override
  Future<void> setAccountToken(String accountId, AccountToken token) async {
    await _prefs.setString("integration_$accountId", jsonEncode(token.toMap()));
  }

  @override
  Future<void> removeAccountToken(String accountId) async {
    await _prefs.remove("integration_$accountId");
  }

  @override
  DateTime? lastSyncForAccountId(String accountId) {
    String? value = _prefs.getString("lastSyncForAccountId_$accountId");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastSyncForAccountId(String accountId, DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastSyncForAccountId_$accountId", value.toIso8601String());
    }
  }

  @override
  bool get firstTimeLoaded {
    return _prefs.getBool("firstTimeLoaded") ?? false;
  }

  @override
  Future<void> setFirstTimeLoaded(bool value) async {
    await _prefs.setBool("firstTimeLoaded", value);
  }

  @override
  bool get onboardingCompleted {
    return _prefs.getBool("onboardingCompleted") ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool("onboardingCompleted", value);
  }

  @override
  bool getV3AccountActive(String accountId) {
    return _prefs.getBool("localV3AccountActive_$accountId") ?? false;
  }

  @override
  Future<void> setV3AccountActive(String accountId, bool active) async {
    await _prefs.setBool("localV3AccountActive_$accountId", active);
  }

  @override
  bool get reconnectPageSkipped {
    return _prefs.getBool("reconnectPageSkipped") ?? false;
  }

  @override
  Future<void> setReconnectPageSkipped(bool value) async {
    await _prefs.setBool("reconnectPageSkipped", value);
  }

  @override
  int get timeFormat {
    return _prefs.getInt("timeFormat") ?? -1;
  }

  @override
  Future<void> setTimeFormat(int value) async {
    await _prefs.setInt("timeFormat", value);
  }

  @override
  String get deviceUUID {
    String? uuid = _prefs.getString("deviceUUID");

    if (uuid == null) {
      uuid = const Uuid().v4();

      _prefs.setString("deviceUUID", uuid);
      return uuid;
    } else {
      return uuid;
    }
  }

  @override
  Future<void> setDeviceUUID(String value) async {
    await _prefs.setString("deviceUUID", value);
  }

  @override
  int get recurringBackgroundSyncCounter {
    return _prefs.getInt("recurring_background_sync_counter") ?? 0;
  }

  @override
  Future<void> setRecurringBackgroundSyncCounter(int value) async {
    await _prefs.setInt("recurring_background_sync_counter", value);
  }

  @override
  int get recurringNotificationsSyncCounter {
    return _prefs.getInt("recurring_notifications_sync_counter") ?? 0;
  }

  @override
  Future<void> setRecurringNotificationsSyncCounter(int value) async {
    await _prefs.setInt("recurring_notifications_sync_counter", value);
  }

  @override
  String get getLastSavedTimeZone {
    return _prefs.getString("last_saved_time_zone") ?? "";
  }

  @override
  Future<void> setLastSavedTimeZone(String value) async {
    await _prefs.setString("last_saved_time_zone", value);
  }

  @override
  DateTime? get lastDayInboxZero {
    String? value = _prefs.getString("lastDayInboxZero");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastDayInboxZero(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastDayInboxZero", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastDayTodayZero {
    String? value = _prefs.getString("lastDayTodayZero");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setDayTodayZero(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastDayTodayZero", value.toIso8601String());
    }
  }

  @override
  DateTime? get lastTaskDoneAt {
    String? value = _prefs.getString("lastTaskDoneAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastTaskDoneAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastTaskDoneAt", value.toIso8601String());
    }
  }
}
