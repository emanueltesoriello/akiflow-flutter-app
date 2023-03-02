import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/nullable.dart';

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
  AtendeeResponseStatus get isLoggedUserAttndingEvent {
    String? response = attendees?.firstWhere((atendee) => atendee.email == originCalendarId).responseStatus;

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
}
