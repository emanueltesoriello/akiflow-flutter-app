import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get shortDateFormatted {
    return DateFormat("d MMM").format(this);
  }

  String get timeFormatted {
    return DateFormat("HH:mm").format(this);
  }

  DateTime next(int day) {
    return add(
      Duration(
        days: (day - weekday) % DateTime.daysPerWeek,
      ),
    );
  }
}
