import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarUtils {
  static StartingDayOfWeek computeFirstDayOfWeekForAppbar(int firstDayOfWeek, BuildContext context) {
    if (firstDayOfWeek == -1) {
      int systemDefault = MaterialLocalizations.of(context).firstDayOfWeekIndex;
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
        case 0:
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
    if (context.read<AuthCubit>().state.user?.settings?["calendar"] != null &&
        context.read<AuthCubit>().state.user?.settings?["calendar"]["firstDayOfWeek"] != null) {
      var firstDayFromDb = context.read<AuthCubit>().state.user?.settings?["calendar"]["firstDayOfWeek"];
      if (firstDayFromDb is String) {
        firstDayOfWeek = int.parse(firstDayFromDb);
      } else if (firstDayFromDb is int) {
        firstDayOfWeek = firstDayFromDb;
      }
    }

    if (firstDayOfWeek == 0) {
      return DateTime.sunday;
    } else if (firstDayOfWeek == -1) {
      int systemDefault = MaterialLocalizations.of(context).firstDayOfWeekIndex;
      if (systemDefault == 0) {
        return DateTime.sunday;
      }
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
}
