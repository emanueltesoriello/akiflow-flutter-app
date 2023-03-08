import 'package:mobile/common/style/colors.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/nullable.dart';
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

  Future<void> openUrl(String? url) async {
    Uri uri = Uri.parse(url ?? '');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print(e);
    }
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
}
