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
  Future<void> setLastLabelsSyncAt(DateTime? value);

  DateTime? get lastEventsSyncAt;
  Future<void> setLastEventsSyncAt(DateTime? value);

  DateTime? get lastDocsSyncAt;
  Future<void> setLastDocsSyncAt(DateTime? value);

  DateTime? get lastGmailSyncAt;
  Future<void> setLastGmailSyncAt(DateTime? value);

  AccountToken? getAccountToken(String accountId);
  Future<void> setAccountToken(String accountId, AccountToken token);
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
  DateTime? get lastGmailSyncAt {
    String? value = _prefs.getString("lastGmailSyncAt");
    return value == null ? null : DateTime.parse(value);
  }

  @override
  Future<void> setLastGmailSyncAt(DateTime? value) async {
    if (value != null) {
      await _prefs.setString("lastGmailSyncAt", value.toIso8601String());
    }
  }

  @override
  AccountToken? getAccountToken(String accountId) {
    String? tokenString = _prefs.getString("accountToken_$accountId");

    if (tokenString == null) {
      return null;
    }

    return AccountToken.fromMap(jsonDecode(tokenString));
  }

  @override
  Future<void> setAccountToken(String accountId, AccountToken token) async {
    await _prefs.setString(accountId, jsonEncode(token.toMap()));
  }
}
