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
      int duration = 1800;
      List<dynamic> taskSettings = settings?["tasks"];
      for (Map<String, dynamic> element in taskSettings) {
        if (element['key'] == 'defaultTasksDuration') {
          var defaultTasksDuration = element['value'];
          if (defaultTasksDuration is String) {
            duration = int.parse(defaultTasksDuration);
          } else if (defaultTasksDuration is int) {
            duration = defaultTasksDuration;
          }
        }
      }
      return duration;
    } catch (e) {
      return 2 * 60 * 60;
    }
  }

  String? get markAsDone {
    try {
      return settings?['popups']['gmail.unstar'].toString();
    } catch (e) {
      return null;
    }
  }
}
