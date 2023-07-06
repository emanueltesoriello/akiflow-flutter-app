import 'package:flutter/material.dart';

class TimeFormatUtils {
  static const int systemDefault = -1;
  static const int twelveHours = 0;
  static const int twentyFourHours = 1;

  static bool use24hFormat({required int timeFormat, required BuildContext context}) {
    switch (timeFormat) {
      case TimeFormatUtils.systemDefault:
        return MediaQuery.of(context).alwaysUse24HourFormat;
      case TimeFormatUtils.twentyFourHours:
        return true;
      case TimeFormatUtils.twelveHours:
        return false;
      default:
        return true;
    }
  }
}
