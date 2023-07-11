import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/src/calendar/ui/models/calendar_event.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/recurrence_modal.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/nullable.dart';
import 'package:rrule/rrule.dart';
import 'package:syncfusion_calendar/calendar.dart';
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

  Future<void> launchMapsUrl() async {
    String location = Uri.encodeFull(content?["location"] ?? '');

    Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$location');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print(e);
    }
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
    return ColorsLight.purple500.value.toRadixString(16);
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

  ///returns rrule on first position and exdate on second
  List<String> computeRuleForThisAndFuture() {
    List<String> parts = recurrence!;
    parts.removeWhere((part) => part.startsWith('WKST'));

    List<String> goodRule = parts.where((part) => !part.startsWith('EXDATE') && !part.startsWith('TZID')).toList();

    parts.removeWhere((part) => goodRule.contains(part));

    return [goodRule.join(";"), parts.join(";")];
  }

  ///returns all the valid events to be scheduled for the next 20 days
  static Future<Map<String, Event>> eventNotifications(
      EventsRepository eventsRepository, List<Calendar> calendars) async {
    DateTime now = DateTime.now().toUtc();
    DateTime endDate = now.add(const Duration(days: 5));

    List<Event> events = await eventsRepository.getEventsBetweenDates(now, endDate);

    List<Event> nonRecurring = <Event>[];
    List<Event> recurringParents = <Event>[];
    List<Event> recurringExceptions = <Event>[];

    //gets the visible calendars in order to process only their events
    List<String> notificationsEnabledCalendarIds = [];
    if (calendars.isNotEmpty) {
      calendars = calendars
          .where((element) =>
              element.settings != null &&
              ((element.settings["notificationsEnabledMobile"] ?? element.settings["notificationsEnabled"] ?? false) ==
                  true))
          .toList();

      for (var calendar in calendars) {
        notificationsEnabledCalendarIds.add(calendar.id!);
      }
    }
    events = events.where((element) => notificationsEnabledCalendarIds.contains(element.calendarId)).toList();

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

      //removing exception dates from the recurrence list
      for (Event exceptionEvent in recurringExceptions) {
        if (exceptionEvent.recurringId == parentEvent.id) {
          if (exceptionEvent.originalStartTime != null || exceptionEvent.originalStartDate != null) {
            hiddenExceptionDates.add(exceptionEvent.originalStartTime != null
                ? DateTime.parse(exceptionEvent.originalStartTime!)
                : DateTime.parse(exceptionEvent.originalStartDate!));
          } else if (exceptionEvent.startTime != null || exceptionEvent.startDate != null) {
            hiddenExceptionDates.add(exceptionEvent.startTime != null
                ? DateTime.parse(exceptionEvent.startTime!)
                : DateTime.parse(exceptionEvent.startDate!));
          }
        }
      }
      List<DateTime> computedEventDates = allEventDates
          .where((element) => !hiddenExceptionDates.contains(element.toUtc()) && element.isAfter(now))
          .toList();
      if (computedEventDates.isNotEmpty) {
        for (DateTime date in computedEventDates) {
          eventsToSchedule.addAll({
            '${generateNotificationIdFromEventId(parentEvent.id!) + date.toUtc().day};${date.toUtc().toIso8601String()}':
                parentEvent
          });
        }
      }
    }

    //processing exceptions
    for (Event exception in recurringExceptions) {
      if (exception.startTime != null || exception.startDate != null) {
        DateTime eventStartTime =
            exception.startTime != null ? DateTime.parse(exception.startTime!) : DateTime.parse(exception.startDate!);
        //validating exceptions by not adding deleted and declined ones
        if (eventStartTime.isAfter(now) &&
            exception.isLoggedUserAttndingEvent != AtendeeResponseStatus.declined &&
            exception.deletedAt == null &&
            exception.status != EventExt.eventStatusCancelled) {
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

  bool isOrganizer() {
    return organizerId == originCalendarId;
  }

  List<EventAtendee> getGuestsExceptOrganizer() {
    if (attendees != null && attendees!.isNotEmpty) {
      return attendees!.where((attendee) => attendee.email != organizerId).toList();
    }
    return [];
  }

  EventAtendee? getOrganizerGuest() {
    if (attendees != null && attendees!.isNotEmpty) {
      try {
        return attendees!.firstWhere((attendee) => attendee.email == organizerId);
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  bool hasOrganizerAccepted() {
    return getOrganizerGuest()?.responseStatus == AtendeeResponseStatus.accepted.id;
  }

  bool hasOrganizerDeclined() {
    return getOrganizerGuest()?.responseStatus == AtendeeResponseStatus.declined.id;
  }

  bool hasOrganizerChosenMaybe() {
    return getOrganizerGuest()?.responseStatus == AtendeeResponseStatus.tentative.id;
  }

  bool haveAllGuestsResponse(AtendeeResponseStatus responseStatus) {
    List<EventAtendee> guestsExceptOrganizer = getGuestsExceptOrganizer();
    if (guestsExceptOrganizer.isEmpty) {
      return false;
    }
    return guestsExceptOrganizer.every((attendee) => attendee.responseStatus == responseStatus.id);
  }

  String? getRsvpIcon() {
    if (attendees == null || (isOrganizer() && attendees!.length < 2)) {
      return null;
    }

    if (isOrganizer()) {
      if (haveAllGuestsResponse(AtendeeResponseStatus.needsAction)) {
        return Assets.images.icons.common.questionSquareFillSVG;
      } else if (haveAllGuestsResponse(AtendeeResponseStatus.accepted)) {
        return null;
      } else if (haveAllGuestsResponse(AtendeeResponseStatus.tentative)) {
        return Assets.images.icons.common.questionSquareFillSVG;
      } else if (haveAllGuestsResponse(AtendeeResponseStatus.declined)) {
        return Assets.images.icons.common.xmarkSquareFillSVG;
      }
    } else {
      if (hasOrganizerAccepted() || haveAllGuestsResponse(AtendeeResponseStatus.accepted)) {
        return null;
      } else if (hasOrganizerDeclined() || haveAllGuestsResponse(AtendeeResponseStatus.declined)) {
        return Assets.images.icons.common.xmarkSquareFillSVG;
      } else if (hasOrganizerChosenMaybe() || haveAllGuestsResponse(AtendeeResponseStatus.tentative)) {
        return Assets.images.icons.common.questionSquareFillSVG;
      }
    }
    return null;
  }

  bool isTimeOrDateValid() {
    if (startTime != null && endTime != null) {
      DateTime startT = DateTime.parse(startTime!);
      DateTime endT = DateTime.parse(endTime!);
      if (startT.isAtSameMomentAs(endT) || startT.isBefore(endT)) {
        return true;
      }
    } else if (startDate != null && endDate != null) {
      DateTime startD = DateTime.parse(startDate!);
      DateTime endD = DateTime.parse(endDate!);
      if (startD.isAtSameMomentAs(endD) || startD.isBefore(endD)) {
        return true;
      }
    }
    return false;
  }
}
