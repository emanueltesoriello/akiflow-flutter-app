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
}
