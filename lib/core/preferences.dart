import 'dart:convert';

import 'package:models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesRepository {
  Future<void> clear();

  Future<void> saveUser(User user);

  User? get user;

  bool get inboxNoticeHidden;

  Future<void> setInboxNoticeHidden(bool value);
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
}
