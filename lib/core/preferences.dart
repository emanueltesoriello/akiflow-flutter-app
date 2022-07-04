import 'dart:convert';

import 'package:models/account/account_token.dart';
import 'package:models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesRepository {
  Future<void> clear();

  Future<void> saveUser(User user);

  User? get user;

  bool get inboxNoticeHidden;

  Future<void> setInboxNoticeHidden(bool value);

  DateTime? get lastAccountsV2SyncAt;
  Future<void> setLastAccountsV2SyncAt(DateTime? value);

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

  DateTime? get lastDocsSyncAt;
  Future<void> setLastDocsSyncAt(DateTime? value);

  DateTime? lastSyncForAccountId(String accountId);
  Future<void> setLastSyncForAccountId(String accountId, DateTime? value);

  AccountToken? getAccountToken(String accountId);
  Future<void> setAccountToken(String accountId, AccountToken token);

  bool get firstTimeLoaded;
  Future<void> setFirstTimeLoaded(bool value);
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
  bool get inboxNoticeHidden {
    return _prefs.getBool("inboxNoticeHidden") ?? false;
  }

  @override
  Future<void> setInboxNoticeHidden(bool value) async {
    await _prefs.setBool("inboxNoticeHidden", value);
  }

  @override
  DateTime? get lastAccountsV2SyncAt {
    String? value = _prefs.getString("lastAccountsV2SyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastAccountsV2SyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastAccountsV2SyncAt", value.toIso8601String());
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
}
