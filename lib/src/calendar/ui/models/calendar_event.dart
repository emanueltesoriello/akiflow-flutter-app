import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:models/event/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  }) {
    DateTime startTime = DateTime(DateTime.now().year - 1, 2, 31);
    DateTime endTime = startTime;

    if (event.deletedAt != null || (event.status != null && event.status == 'cancelled')) {
      return CalendarEvent(id: event.id, startTime: startTime, endTime: endTime, isAllDay: true, notes: 'deleted');
    }

    if (event.startTime != null && event.endTime != null) {
      startTime = DateTime.parse(event.startTime!).toLocal();
      endTime = DateTime.parse(event.endTime!).toLocal();
    } else if (event.startDate != null && event.endDate != null) {
      startTime = DateTime.parse(event.startDate!).toLocal();
      endTime = DateTime.parse(event.endDate!).toLocal();
    }

    List<DateTime>? exceptionDates = [];
    if (isRecurringParent && exceptions != null) {
      for (var element in exceptions) {
        if (element.recurringId == event.id) {
          if (element.startTime != null || element.startDate != null) {
            exceptionDates.add(
                element.startTime != null ? DateTime.parse(element.startTime!) : DateTime.parse(element.startDate!));
          } else if (element.originalStartTime != null || element.originalStartDate != null) {
            exceptionDates.add(element.originalStartTime != null
                ? DateTime.parse(element.originalStartTime!)
                : DateTime.parse(element.originalStartDate!));
          }
        }
      }
    }

    String? formatedRrule;
    try {
      if (isRecurringParent && event.recurrence != null && event.recurrence!.isNotEmpty) {
        List<String> parts = event.recurrence!.first.replaceFirst('RRULE:', '').split(";");
        formatedRrule = computeRrule(parts);
      }
    } catch (e) {
      print(e);
      SentryService sentryService = locator<SentryService>();
      sentryService.addBreadcrumb(category: "calendar_event", message: e.toString());
    }

    return CalendarEvent(
      id: event.id,
      startTime: startTime,
      endTime: endTime,
      subject: event.title ?? '',
      color: event.color != null
          ? Color(int.parse(event.color!.replaceAll('#', '0xff')))
          : event.calendarColor != null
              ? Color(int.parse(event.calendarColor!.replaceAll('#', '0xff')))
              : ColorsExt.cyan(context),
      isAllDay: event.startTime == null && event.endTime == null,
      recurrenceId: isRecurringException ? [event.recurringId] : null,
      recurrenceRule: formatedRrule,
      recurrenceExceptionDates: exceptionDates.isNotEmpty ? exceptionDates : null,
    );
  }

  static String? computeRrule(List<String> parts) {
    parts.removeWhere((part) => part.startsWith('WKST'));

    List<String> byDay = parts.where((part) => part.startsWith('BYDAY')).toList();
    if (byDay.isNotEmpty) {
      List<String> days = byDay.first.replaceFirst('BYDAY=', '').split(',');
      List<int> bySetPos = [];
      for (int i = 0; i < days.length; i++) {
        if (days[i].startsWith(RegExp(r'[0-9]'))) {
          bySetPos.add(int.parse(days[i].replaceAll(RegExp(r'[a-zA-Z]'), '')));
          days[i] = days[i].replaceAll(RegExp(r'[0-9]'), '');
        }
      }
      parts.removeWhere((part) => part.startsWith('BYDAY'));

      String byDayString = days.join(',');
      parts.add('BYDAY=$byDayString');

      String bySetPosString = bySetPos.join(',');
      if (bySetPosString.isNotEmpty) {
        parts.add('BYSETPOS=$bySetPosString');
      }
    }

    String? recurrenceString = parts.join(';');
    return recurrenceString;
  }
}
