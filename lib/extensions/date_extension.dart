import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  int daysBetween(DateTime to) {
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(this).inHours / 24).round();
  }

  String get shortDateFormatted {
    return DateFormat("d MMM").format(this);
  }

  String get timeFormatted {
    return DateFormat("HH:mm").format(this);
  }
}
