import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
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
    DateTime startTime = DateTime(DateTime.now().year-1, 2, 31);
    DateTime endTime = startTime;
    if (event.startTime != null && event.endTime != null) {
      startTime = DateTime.parse(event.startTime!);
      endTime = DateTime.parse(event.endTime!);
    } else if (event.startDate != null && event.endDate != null) {
      startTime = DateTime.parse(event.startDate!);
      endTime = DateTime.parse(event.endDate!);
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

    if (event.deletedAt != null) {
      return CalendarEvent(id: event.id, startTime: startTime, endTime: endTime, isAllDay: true, notes: 'deleted');
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
      recurrenceRule: isRecurringParent && event.recurrence != null && event.recurrence!.isNotEmpty
          ? event.recurrence!.first
          : null,
      recurrenceExceptionDates: exceptionDates.isNotEmpty ? exceptionDates : null,
    );
  }
}
