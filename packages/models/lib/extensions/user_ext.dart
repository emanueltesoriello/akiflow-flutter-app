import 'package:models/user.dart';

extension UserExt on User {
  int get defaultHour {
    try {
      return settings!["tasks"]["snooze.defaultHour"];
    } catch (e) {
      return 8;
    }
  }

  int get defaultDuration {
    try {
      return settings!["tasks"]["defaultTasksDuration"];
    } catch (e) {
      return 2 * 60 * 60;
    }
  }
}
