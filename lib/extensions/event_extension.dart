import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/models/calendar_event.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/recurrence_modal.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/nullable.dart';
import 'package:rrule/rrule.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

enum AtendeeResponseStatus { needsAction, accepted, declined, tentative }

extension TaskStatusTypeExt on AtendeeResponseStatus {
  String get id {
    switch (this) {
      case AtendeeResponseStatus.needsAction:
        return 'needsAction';
      case AtendeeResponseStatus.accepted:
        return 'accepted';
      case AtendeeResponseStatus.declined:
        return 'declined';
      case AtendeeResponseStatus.tentative:
        return 'tentative';
    }
  }

  static AtendeeResponseStatus? fromId(int? id) {
    switch (id) {
      case 1:
        return AtendeeResponseStatus.needsAction;
      case 2:
        return AtendeeResponseStatus.accepted;
      case 3:
        return AtendeeResponseStatus.declined;
      case 4:
        return AtendeeResponseStatus.tentative;
      default:
        return null;
    }
  }

  static AtendeeResponseStatus fromString(String? id) {
    switch (id) {
      case 'needsAction':
        return AtendeeResponseStatus.needsAction;
      case 'accepted':
        return AtendeeResponseStatus.accepted;
      case 'declined':
        return AtendeeResponseStatus.declined;
      case 'tentative':
        return AtendeeResponseStatus.tentative;
      default:
        return AtendeeResponseStatus.needsAction;
    }
  }
}

extension EventExt on Event {
  static String akiflowSignature = 'Scheduled with Akiflow';
  static String eventStatusCancelled = 'cancelled';

  bool canModify() {
    return !(readOnly ?? false) &&
        (creatorId == originCalendarId ||
            organizerId == originCalendarId ||
            (organizerId != originCalendarId && content != null && (content["guestsCanModify"] ?? false)));
  }

  AtendeeResponseStatus get isLoggedUserAttndingEvent {
    String? response;
    try {
      response = attendees?.firstWhere((atendee) => atendee.email == originCalendarId).responseStatus;
    } catch (e) {
      print(e);
    }

    if (response != null) {
      return TaskStatusTypeExt.fromString(response);
    }
    return AtendeeResponseStatus.needsAction;
  }

  setLoggedUserAttendingResponse(AtendeeResponseStatus response) {
    List<EventAtendee> updatedAtendees = attendees!;
    EventAtendee loggedUser = attendees!.firstWhere((atendee) => atendee.email == originCalendarId);
    loggedUser = loggedUser.copyWith(responseStatus: response.id);
    updatedAtendees.removeWhere((attendee) => attendee.email == originCalendarId);
    updatedAtendees.add(loggedUser);
    copyWith(attendees: Nullable(updatedAtendees));
  }

  String computeStartTimeForParent(Event updatedEvent) {
    DateTime parentOriginalStartTime = DateTime.parse(startTime!).toLocal();
    DateTime updatedStartTime = DateTime.parse(updatedEvent.startTime!).toLocal();

    DateTime computedStartTime = DateTime(
            parentOriginalStartTime.year,
            parentOriginalStartTime.month,
            parentOriginalStartTime.day,
            updatedStartTime.hour,
            updatedStartTime.minute,
            updatedStartTime.second,
            updatedStartTime.millisecond)
        .toUtc();

    return computedStartTime.toIso8601String();
  }

  String computeEndTimeForParent(Event updatedEvent) {
    DateTime parentOriginalEndTime = DateTime.parse(endTime!).toLocal();
    DateTime updatedEndTime = DateTime.parse(updatedEvent.endTime!).toLocal();

    DateTime computedEndTime = DateTime(
            parentOriginalEndTime.year,
            parentOriginalEndTime.month,
            parentOriginalEndTime.day,
            updatedEndTime.hour,
            updatedEndTime.minute,
            updatedEndTime.second,
            updatedEndTime.millisecond)
        .toUtc();

    return computedEndTime.toIso8601String();
  }

  Future<void> joinConference() async {
    openUrl(meetingUrl).then(
      (urlOpened) {
        if (urlOpened != null && urlOpened) {
          AnalyticsService.track("Join call", properties: {
            "mobile": true,
            "mode": "click",
            "origin": "eventModal",
          });
        }
      },
    );
  }

  Future<bool?> openUrl(String? url) async {
    Uri uri = Uri.parse(url ?? '');
    bool urlOpened = false;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      urlOpened = true;
    } catch (e) {
      print(e);
    }
    return urlOpened;
  }

  Future<void> sendEmail() async {
    String recipients = attendees!.map((e) => e.email!).toList().join(",");
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: recipients,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Calendar event: $title',
      }),
    );
    print(emailLaunchUri);
    try {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print(e);
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  static Map<String, String> eventColor = {
    '#a4bdfc': '#7986cb',
    '#7ae7bf': '#33b679',
    '#dbadff': '#8e24aa',
    '#ff887c': '#e67c73',
    '#fbd75b': '#f6bf26',
    '#ffb878': '#f4511e',
    '#46d6db': '#039be5',
    '#e1e1e1': '#616161',
    '#5484ed': '#3f51b5',
    '#51b749': '#0b8043',
    '#dc2127': '#d50000',
  };

  static Map<String, String> calendarColor = {
    '#ac725e': '#795548',
    '#d06b64': '#e67c73',
    '#f83a22': '#d50000',
    '#fa573c': '#f4511e',
    '#ff7537': '#ef6c00',
    '#ffad46': '#f09300',
    '#42d692': '#009688',
    '#16a765': '#0b8043',
    '#7bd148': '#7cb342',
    '#b3dc6c': '#c0ca33',
    '#fbe983': '#e4c441',
    '#fad165': '#f6bf26',
    '#92e1c0': '#33b679',
    '#9fe1e7': '#039be5',
    '#9fc6e7': '#4285f4',
    '#4986e7': '#3f51b5',
    '#9a9cff': '#7986cb',
    '#b99aff': '#b39ddb',
    '#c2c2c2': '#616161',
    '#cabdbf': '#a79b8e',
    '#cca6ac': '#ad1457',
    '#f691b2': '#d81b60',
    '#cd74e6': '#8e24aa',
    '#a47ae2': '#9e69af'
  };

  static String computeColor(Event event) {
    if (event.color != null) {
      return eventColor[event.color] ?? event.color!;
    } else if (event.calendarColor != null) {
      return calendarColor[event.calendarColor] ?? event.calendarColor!;
    }
    return ColorsLight.akiflow.value.toRadixString(16);
  }

  RecurrenceRule? get ruleFromStringList {
    if (recurrence != null) {
      try {
        List<String> parts = recurrence!.first.split(";");

        parts.removeWhere((part) => part.startsWith('DTSTART'));
        print("Recurrence $recurrence");
        String recurrenceString = parts.join(';');
        return RecurrenceRule.fromString(recurrenceString);
      } catch (e) {
        print("Recurrence from String parsing error: $e");
      }
    }
    return null;
  }

  EventRecurrenceModalType get recurrenceComputed {
    if (recurrence != null) {
      try {
        List<String> parts = recurrence!.first.split(";");

        parts.removeWhere((part) => part.startsWith('DTSTART'));

        String recurrenceString = parts.join(';');

        if (recurrenceString.isEmpty) {
          return EventRecurrenceModalType.none;
        }

        RecurrenceRule rule = RecurrenceRule.fromString(recurrenceString);

        if (rule.frequency == Frequency.daily && rule.interval == null) {
          return EventRecurrenceModalType.daily;
        } else if (rule.frequency == Frequency.weekly && rule.byWeekDays.length == 5) {
          return EventRecurrenceModalType.everyWeekday;
        } else if (rule.frequency == Frequency.yearly && rule.interval == null) {
          return EventRecurrenceModalType.everyYearOnThisDay;
        } else if (rule.frequency == Frequency.monthly && rule.interval == null && rule.hasByMonthDays) {
          return EventRecurrenceModalType.everyMonthOnThisDay;
        } else if (rule.frequency == Frequency.weekly && rule.interval == null) {
          return EventRecurrenceModalType.everyCurrentDay;
        } else if (rule.interval != null || rule.byWeekDays.length > 1) {
          return EventRecurrenceModalType.custom;
        }
      } catch (e) {
        print("Recurrence parsing error: $e");
      }
    }

    return EventRecurrenceModalType.none;
  }

  String recurrenceRuleComputed(RecurrenceRule rule) {
    String computedRule = rule.toString();
    List<String> parts = computedRule.split(";");
    String? untilString;
    try {
      untilString = parts.where((part) => part.startsWith('UNTIL')).first;
    } catch (e) {
      print(e);
    }
    if (untilString != null) {
      if (!untilString.endsWith('Z')) {
        parts.removeWhere((part) => part.startsWith('UNTIL'));
        untilString = '${untilString}Z';
        parts.add(untilString);
      }
    }
    computedRule = parts.join(";");
    return computedRule;
  }

  ///returns all the valid events to be scheduled for the next 20 days
  static Future<Map<String, Event>> eventNotifications() async {
    DateTime now = DateTime.now().toUtc();
    DateTime endDate = now.add(const Duration(days: 20));
    EventsRepository eventsRepository = locator<EventsRepository>();
    List<Calendar> calendars = locator<CalendarCubit>().state.calendars;

    List<Event> events = await eventsRepository.getEventsBetweenDates(now, endDate);

    List<Event> nonRecurring = <Event>[];
    List<Event> recurringParents = <Event>[];
    List<Event> recurringExceptions = <Event>[];

    //gets the visible calendars in order to process only their events
    List<String> visibleCalendarIds = [];
    if (calendars.isNotEmpty) {
      calendars = calendars
          .where((element) =>
              element.settings != null &&
              ((element.settings["visibleMobile"] ?? element.settings["visible"] ?? false) == true))
          .toList();

      for (var calendar in calendars) {
        visibleCalendarIds.add(calendar.id!);
      }
    }
    events = events.where((element) => visibleCalendarIds.contains(element.calendarId)).toList();

    nonRecurring = events.where((event) => event.recurringId == null).toList();
    recurringParents = events.where((event) => event.id == event.recurringId).toList();
    recurringExceptions = events.where((event) => event.recurringId != null && event.recurringId != event.id).toList();

    Map<String, Event> eventsToSchedule = {};

    //processing non recurring events
    for (Event event in nonRecurring) {
      DateTime eventStartTime =
          event.startTime != null ? DateTime.parse(event.startTime!) : DateTime.parse(event.startDate!);
      if (eventStartTime.isAfter(now)) {
        eventsToSchedule
            .addAll({'${generateNotificationIdFromEventId(event.id!)};${eventStartTime.toIso8601String()}': event});
      }
    }

    //processing parent events
    for (Event parentEvent in recurringParents) {
      String? formatedRrule;
      DateTime startTime = parentEvent.startTime != null
          ? DateTime.parse(parentEvent.startTime!)
          : DateTime.parse(parentEvent.startDate!);
      List<String> parts = parentEvent.recurrence!.first.replaceFirst('RRULE:', '').split(";");
      formatedRrule = CalendarEvent.computeRrule(parts, startTime);

      List<DateTime> allEventDates = SfCalendar.getRecurrenceDateTimeCollection(
          formatedRrule ?? '', startTime.toLocal(),
          specificStartDate: now, specificEndDate: endDate);
      List<DateTime> hiddenExceptionDates = [];

      //removing deleted and declined event exception dates
      for (Event exceptionEvent in recurringExceptions) {
        if (exceptionEvent.recurringId == parentEvent.id) {
          if (exceptionEvent.originalStartTime != null || exceptionEvent.originalStartDate != null) {
            if (exceptionEvent.isLoggedUserAttndingEvent == AtendeeResponseStatus.declined ||
                exceptionEvent.deletedAt != null ||
                (exceptionEvent.status != null && exceptionEvent.status == EventExt.eventStatusCancelled)) {
              hiddenExceptionDates.add(exceptionEvent.originalStartTime != null
                  ? DateTime.parse(exceptionEvent.originalStartTime!)
                  : DateTime.parse(exceptionEvent.originalStartDate!));
            }
          } else if (exceptionEvent.startTime != null || exceptionEvent.startDate != null) {
            if (exceptionEvent.isLoggedUserAttndingEvent == AtendeeResponseStatus.declined ||
                exceptionEvent.deletedAt != null ||
                (exceptionEvent.status != null && exceptionEvent.status == EventExt.eventStatusCancelled)) {
              hiddenExceptionDates.add(exceptionEvent.startTime != null
                  ? DateTime.parse(exceptionEvent.startTime!)
                  : DateTime.parse(exceptionEvent.startDate!));
            }
          }
        }
      }
      List<DateTime> computedEventDates = allEventDates
          .where((element) => !hiddenExceptionDates.contains(element.toUtc()) && element.isAfter(now))
          .toList();
      if (computedEventDates.isNotEmpty) {
        for (DateTime date in computedEventDates) {
          eventsToSchedule.addAll(
              {'${generateNotificationIdFromEventId(parentEvent.id!)};${date.toUtc().toIso8601String()}': parentEvent});
        }
      }
    }

    //processing exceptions
    for (Event exception in recurringExceptions) {
      if (exception.startTime != null || exception.startDate != null) {
        DateTime eventStartTime =
            exception.startTime != null ? DateTime.parse(exception.startTime!) : DateTime.parse(exception.startDate!);
        if (eventStartTime.isAfter(now) && exception.isLoggedUserAttndingEvent != AtendeeResponseStatus.declined) {
          eventsToSchedule.addAll(
              {'${generateNotificationIdFromEventId(exception.id!)};${eventStartTime.toIso8601String()}': exception});
        }
      }
    }
    return eventsToSchedule;
  }

  static int generateNotificationIdFromEventId(String eventId) {
    int notificationsId = 0;

    try {
      // get the last 8 hex char from the ID and convert them into an int
      notificationsId = (int.parse(eventId.substring(eventId.length - 8, eventId.length), radix: 16) / 2).round();
    } catch (e) {
      notificationsId = eventId.hashCode;
    }
    return notificationsId;
  }
}
