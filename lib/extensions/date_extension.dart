import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  double daysBetween(DateTime to) {
    to = DateTime(to.year, to.month, to.day);
    return (difference(to).inHours / 24);
  }

  bool daysBetweenLessThanHundred(DateTime? to) {
    if (to != null) {
      to = DateTime(to.year, to.month, to.day);
      return daysBetween(to) < 100;
    }
    return true;
  }

  String get shortDateFormatted {
    return DateFormat("d MMM").format(this);
  }

  String get timeFormatted {
    return DateFormat("HH:mm").format(this);
  }
}
