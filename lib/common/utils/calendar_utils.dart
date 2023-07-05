import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarUtils {
  static StartingDayOfWeek computeFirstDayOfWeekForAppbar(int firstDayOfWeek, BuildContext context) {
    if (firstDayOfWeek == -1) {
      int systemDefault = context.read<CalendarCubit>().state.systemStartOfWeekDay;
      switch (systemDefault) {
        case DateTime.monday:
          return StartingDayOfWeek.monday;
        case DateTime.tuesday:
          return StartingDayOfWeek.tuesday;
        case DateTime.wednesday:
          return StartingDayOfWeek.wednesday;
        case DateTime.thursday:
          return StartingDayOfWeek.thursday;
        case DateTime.friday:
          return StartingDayOfWeek.friday;
        case DateTime.saturday:
          return StartingDayOfWeek.saturday;
        case DateTime.sunday:
          return StartingDayOfWeek.sunday;
        default:
          return StartingDayOfWeek.monday;
      }
    } else {
      switch (firstDayOfWeek) {
        case DateTime.monday:
          return StartingDayOfWeek.monday;
        case DateTime.tuesday:
          return StartingDayOfWeek.tuesday;
        case DateTime.wednesday:
          return StartingDayOfWeek.wednesday;
        case DateTime.thursday:
          return StartingDayOfWeek.thursday;
        case DateTime.friday:
          return StartingDayOfWeek.friday;
        case DateTime.saturday:
          return StartingDayOfWeek.saturday;
        case 0:
          return StartingDayOfWeek.sunday;
        default:
          return StartingDayOfWeek.monday;
      }
    }
  }

  static int computeFirstDayOfWeek(BuildContext context) {
    int firstDayOfWeek = DateTime.monday;
    AuthCubit authCubit = context.read<AuthCubit>();
    if (authCubit.state.user?.settings?["calendar"] != null) {
      List<dynamic> calendarSettings = authCubit.state.user?.settings?["calendar"];
      for (Map<String, dynamic> element in calendarSettings) {
        if (element['key'] == 'firstDayOfWeek') {
          var firstDayFromDb = element['value'];
          if (firstDayFromDb != null) {
            if (firstDayFromDb is String) {
              firstDayOfWeek = int.parse(firstDayFromDb);
            } else if (firstDayFromDb is int) {
              firstDayOfWeek = firstDayFromDb;
            }
          }
        }
      }
    }

    if (firstDayOfWeek == 0) {
      return DateTime.sunday;
    } else if (firstDayOfWeek == -1) {
      int systemDefault = context.read<CalendarCubit>().state.systemStartOfWeekDay;
      return systemDefault;
    } else {
      return firstDayOfWeek;
    }
  }

  /// firstWorkingDayOfWeek where Sunday=0, Monday=1 .. Saturday=6
  /// return last 2 days of week, in another format: Monday=1, Tuesday=2 .. Sunday=7
  static List<int> getNonWorkingDays(int firstWorkingDayOfWeek) {
    List<int> nonWorkingDays = [];
    int lastWorkingDayOfWeek = (firstWorkingDayOfWeek + 5) % 7;
    int secondLastDayOfWeek = (lastWorkingDayOfWeek + 6) % 7;
    nonWorkingDays.add(secondLastDayOfWeek + 1);
    nonWorkingDays.add(lastWorkingDayOfWeek + 1);
    return nonWorkingDays;
  }

  static const platform = MethodChannel('com.akiflow.mobile/firstDayOfWeek');

  static Future<int> retrieveSystemFirstDayOfWeek() async {
    try {
      final int result = await platform.invokeMethod('getFirstDayOfWeek');

      int firstDayOfWeek;
      if (Platform.isAndroid) {
        firstDayOfWeek = convertAndroidDaysToFlutter(result);
      } else {
        firstDayOfWeek = convertiOSDaysToFlutter(result);
      }
      return firstDayOfWeek;
    } on PlatformException catch (e) {
      print("Failed to retrieve first day of the week: ${e.message}");
      return DateTime.monday;
    }
  }

  static int convertAndroidDaysToFlutter(int androidDay) {
    if (androidDay == 1) {
      return DateTime.sunday;
    } else {
      return androidDay - 1;
    }
  }

  static int convertiOSDaysToFlutter(int iOSDay) {
    if (iOSDay == 1) {
      return DateTime.sunday;
    } else {
      return iOSDay + 1;
    }
  }
}
