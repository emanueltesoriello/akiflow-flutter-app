import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:models/event/event.dart';
import 'package:syncfusion_calendar/calendar.dart';

class CalendarEvent extends Appointment {
  CalendarEvent(
      {required super.startTime,
      required super.endTime,
      super.color,
      super.endTimeZone,
      super.id,
      super.isAllDay,
      super.location,
      super.notes,
      super.recurrenceExceptionDates,
      super.recurrenceId,
      super.recurrenceRule,
      super.resourceIds,
      super.startTimeZone,
      super.subject});

  static CalendarEvent fromEvent({
    required BuildContext context,
    required Event event,
    required bool isRecurringParent,
    required bool isRecurringException,
    required bool isNonRecurring,
    List<Event>? exceptions,
    bool? areDeclinedEventsHidden,
  }) {
    DateTime startTime = DateTime(DateTime.now().year - 1, 2, 31);
    DateTime endTime = startTime;

    //used to hide deleted events
    if (event.deletedAt != null || (event.status != null && event.status == 'cancelled')) {
      return CalendarEvent(id: event.id, startTime: startTime, endTime: endTime, isAllDay: true, notes: 'deleted');
    }

    //used to hide declined events (used specially for declined exceptions)
    if (areDeclinedEventsHidden != null &&
        areDeclinedEventsHidden &&
        event.isLoggedUserAttndingEvent == AtendeeResponseStatus.declined) {
      return CalendarEvent(id: event.id, startTime: startTime, endTime: endTime, isAllDay: true, notes: 'deleted');
    }

    if (event.startTime != null && event.endTime != null) {
      startTime = DateTime.parse(event.startTime!).toLocal();
      endTime = DateTime.parse(event.endTime!).toLocal();
    } else if (event.startDate != null && event.endDate != null) {
      startTime = DateTime.parse(event.startDate!).toLocal();
      endTime = DateTime.parse(event.endDate!).toLocal();
    }

    //gets the exceptions and adds them to the parent's "exceptionDates"
    List<DateTime>? exceptionDates = [];
    if (isRecurringParent && exceptions != null) {
      for (var element in exceptions) {
        if (element.recurringId == event.id) {
          if (element.originalStartTime != null || element.originalStartDate != null) {
            exceptionDates.add(element.originalStartTime != null
                ? DateTime.parse(element.originalStartTime!).toLocal()
                : DateTime.parse(element.originalStartDate!).toLocal());
          } else if (element.startTime != null || element.startDate != null) {
            exceptionDates.add(element.startTime != null
                ? DateTime.parse(element.startTime!).toLocal()
                : DateTime.parse(element.startDate!).toLocal());
          }
        }
      }
    }

    String? formatedRrule;
    SentryService sentryService = locator<SentryService>();
    try {
      if (isRecurringParent && event.recurrence != null && event.recurrence!.isNotEmpty) {
        List<String> parts = event.recurrence!.first.replaceFirst('RRULE:', '').split(";");
        formatedRrule = computeRrule(parts, startTime);
        //TODO: remove this after fixing all possible rrule use cases
        sentryService.addBreadcrumb(
            category: "calendar_event", message: 'event id: ${event.id} formattedRrule: $formatedRrule');
      }
    } catch (e) {
      print(e);
      sentryService.addBreadcrumb(category: "calendar_event", message: e.toString());
    }

    return CalendarEvent(
      id: event.id,
      startTime: startTime,
      endTime: endTime,
      subject: event.title ?? '',
      color: ColorsExt.fromHex(EventExt.computeColor(event)),
      isAllDay: event.startTime == null && event.endTime == null,
      recurrenceId: isRecurringException ? [event.recurringId] : null,
      recurrenceRule: formatedRrule,
      recurrenceExceptionDates: exceptionDates.isNotEmpty ? exceptionDates : null,
    );
  }

  ///used for making the rrule to be accepted by the calendar package
  static String? computeRrule(List<String> parts, DateTime startTime) {
    parts.removeWhere((part) => part.startsWith('WKST'));

    List<String> byDay = parts.where((part) => part.startsWith('BYDAY')).toList();
    if (byDay.isNotEmpty) {
      List<String> days = byDay.first.replaceFirst('BYDAY=', '').split(',');
      List<int> bySetPos = [];
      for (int i = 0; i < days.length; i++) {
        if (days[i].startsWith(RegExp(r'-?\+?[0-9]'))) {
          bySetPos.add(int.parse(days[i].replaceAll(RegExp(r'[a-zA-Z]'), '')));
          days[i] = days[i].replaceAll(RegExp(r'-?\+?[0-9]'), '');
        }
      }
      DateTime startUtc = startTime.toUtc();
      DateTime startUtcLocal =
          DateTime(startUtc.year, startUtc.month, startUtc.day, startUtc.hour, startUtc.minute, startUtc.millisecond);
      if (days.length == 1 && startUtcLocal.day != startTime.day) {
        days[0] = dayOfWeekComputed(startTime.weekday)!;
      }

      parts.removeWhere((part) => part.startsWith('BYDAY'));

      String byDayString = days.join(',');
      parts.add('BYDAY=$byDayString');

      if (parts.where((part) => part.startsWith('BYSETPOS=')).isEmpty && bySetPos.isEmpty) {
        bySetPos.add(1);
      }
      String bySetPosString = bySetPos.join(',');
      if (bySetPosString.isNotEmpty) {
        parts.add('BYSETPOS=$bySetPosString');
      }
    } else if (parts.where((part) => part.startsWith('FREQ=WEEKLY')).isNotEmpty) {
      int dayOfWeek = startTime.weekday;
      String? day = dayOfWeekComputed(dayOfWeek);
      if (day != null) {
        parts.add('BYDAY=$day');
      }
    } else if (parts.where((part) => part.startsWith('BYMONTHDAY=')).isNotEmpty &&
        parts.where((part) => part.startsWith('BYMONTH=')).isEmpty) {
      parts.add('BYMONTH=${startTime.month}');
    }

    String? recurrenceString = parts.join(';');
    return recurrenceString;
  }

  static String? dayOfWeekComputed(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday:
        return "MO";
      case DateTime.tuesday:
        return "TU";
      case DateTime.wednesday:
        return "WE";
      case DateTime.thursday:
        return "TH";
      case DateTime.friday:
        return "FR";
      case DateTime.saturday:
        return "SA";
      case DateTime.sunday:
        return "SU";
      default:
        return null;
    }
  }
}
