import 'package:flutter/widgets.dart';
import 'package:mobile/src/calendar/ui/models/grouped_tasks.dart';
import 'package:syncfusion_calendar/calendar.dart';

class CalendarGroupedTasks extends Appointment {
  CalendarGroupedTasks({
    required super.startTime,
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
    super.subject,
  });

  static CalendarGroupedTasks groupToCaalendarGroupedTask(BuildContext context, GroupedTasks groupedTasks) {
    DateTime startTime = groupedTasks.startTime.toLocal();
    DateTime endTime = groupedTasks.endTime.toLocal();
    /**
     * task longer than 24h will be shown until midnight of the starting day
     */
    int duration = groupedTasks.endTime.difference(groupedTasks.startTime).inSeconds;
    if (duration > 86399) {
      DateTime startTimeMidnight = DateTime(startTime.year, startTime.month, startTime.day, 23, 59, 59);
      endTime = startTime.add(Duration(minutes: startTimeMidnight.difference(startTime).inMinutes));
    }

    return CalendarGroupedTasks(
      startTime: startTime,
      endTime: endTime,
      subject: 'Tasks',
      id: groupedTasks.id,
    );
  }
}
