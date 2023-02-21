import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/contacts_repository.dart';
import 'package:mobile/core/repository/event_modifiers_repository.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:models/contact/contact.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/event/event_modifier.dart';
import 'package:models/nullable.dart';
import 'package:uuid/uuid.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsCubitState> {
  final EventsRepository _eventsRepository = locator<EventsRepository>();
  final EventModifiersRepository _eventModifiersRepository = locator<EventModifiersRepository>();
  final ContactsRepository _contactsRepository = locator<ContactsRepository>();
  final SyncCubit _syncCubit;

  EventsCubit(this._syncCubit) : super(const EventsCubitState());

  Future<void> fetchEventsBetweenDates(String startDate, String endDate) async {
    List<Event> events = await _eventsRepository.getEventsBetweenDates(startDate, endDate);
    emit(state.copyWith(events: events));
  }

  Future<void> fetchSearchedContacts(String query) async {
    List<Contact> searchedContacts = await _contactsRepository.getSearchedContacts(query);
    emit(state.copyWith(searchedContacts: searchedContacts));
  }

  void refetchEvent(Event updatedEvent) async {
    Event fetchedEvent = await _eventsRepository.getById(updatedEvent.id);
    emit(state.copyWith(
      events: state.events.map((event) => event.id == updatedEvent.id ? fetchedEvent : event).toList(),
    ));
  }

  Future<void> scheduleEventsSync() async {
    Future.delayed(const Duration(seconds: 4)).whenComplete(() => _syncCubit.sync(entities: [Entity.events]));
  }

  String getDefaultConferenceSolution() {
    String conferenceSolution = 'meet';
    AuthCubit authCubit = locator<AuthCubit>();
    if (authCubit.state.user?.settings?['calendar']['conferenceSolution'] != null) {
      conferenceSolution = authCubit.state.user?.settings?['calendar']['conferenceSolution'];
    }
    return conferenceSolution;
  }

  String getDefaultConferenceIcon() {
    String conferenceSolution = 'meet';
    AuthCubit authCubit = locator<AuthCubit>();
    if (authCubit.state.user?.settings?['calendar']['conferenceSolution'] != null) {
      conferenceSolution = authCubit.state.user?.settings?['calendar']['conferenceSolution'];
    }
    if (conferenceSolution == 'zoom') {
      return Assets.images.icons.zoom.zoomSVG;
    }
    return Assets.images.icons.google.meetSVG;
  }

  Future<void> updateAtend(Event event, String response) async {
    EventModifier eventModifier = EventModifier(
        id: const Uuid().v4(),
        akiflowAccountId: event.akiflowAccountId,
        eventId: event.id,
        calendarId: event.calendarId,
        action: 'attendees/updateRsvp',
        content: {"responseStatus": response},
        createdAt: DateTime.now().toUtc().toIso8601String());
    _eventModifiersRepository.add([eventModifier]);

    _syncCubit.sync(entities: [Entity.eventModifiers]);
    await scheduleEventsSync();
    refetchEvent(event);
  }

  Future<void> updateEventAndCreateModifiers(Event event, List<String> atendeesToAdd, List<String> atendeesToRemove,
      bool addMeeting, bool removeMeeting) async {
    if (atendeesToAdd.isNotEmpty || atendeesToRemove.isNotEmpty) {
      EventModifier eventModifier = EventModifier(
          id: const Uuid().v4(),
          akiflowAccountId: event.akiflowAccountId,
          eventId: event.id,
          calendarId: event.calendarId,
          action: 'attendees/updateList',
          content: {
            "attendeeEmailsToAdd": atendeesToAdd,
            "attendeeEmailsToRemove": atendeesToRemove,
          },
          createdAt: DateTime.now().toUtc().toIso8601String());
      await _eventModifiersRepository.add([eventModifier]);
    }
    if (addMeeting || event.meetingUrl == null) {
      await _eventModifiersRepository.add([addMeetingEventModifier(event)]);
      print(addMeetingEventModifier(event));
    }
    if (removeMeeting) {
      await _eventModifiersRepository.add([removeMeetingEventModifier(event)]);
    }
    await _eventsRepository.updateById(event.id, data: event);
    refetchEvent(event);
    await _syncCubit.sync(entities: [Entity.eventModifiers, Entity.events]);
    await scheduleEventsSync();
    refetchEvent(event);
  }

  EventModifier addMeetingEventModifier(Event event) {
    String meetingSolution = getDefaultConferenceSolution();
    AuthCubit authCubit = locator<AuthCubit>();

    dynamic content;
    if (meetingSolution == 'zoom') {
      String? conferenceAccountId;
      if (authCubit.state.user?.settings?['calendar']['conferenceAccountId'] != null) {
        conferenceAccountId = authCubit.state.user?.settings?['calendar']['conferenceAccountId'];
      }
      if (conferenceAccountId != null) {
        content = {"meetingSolution": meetingSolution, "akiflowAccountId": conferenceAccountId};
      }
    } else {
      content = {
        "meetingSolution": meetingSolution,
      };
    }

    EventModifier eventModifier = EventModifier(
        id: const Uuid().v4(),
        akiflowAccountId: event.akiflowAccountId,
        eventId: event.id,
        calendarId: event.calendarId,
        action: 'meeting/add',
        content: content,
        createdAt: DateTime.now().toUtc().toIso8601String());
    return eventModifier;
  }

  EventModifier removeMeetingEventModifier(Event event) {
    EventModifier eventModifier = EventModifier(
        id: const Uuid().v4(),
        akiflowAccountId: event.akiflowAccountId,
        eventId: event.id,
        calendarId: event.calendarId,
        action: 'meeting/remove',
        content: const {},
        createdAt: DateTime.now().toUtc().toIso8601String());
    return eventModifier;
  }

  Future<void> fetchUnprocessedEventModifiers(String eventId) async {
    List<EventModifier> unprocessed = await _eventModifiersRepository.getUnprocessedEventModifiersByEventId(eventId);
    emit(state.copyWith(unprocessedEventModifiers: unprocessed));
  }

  Event patchEventWithEventModifier(Event event) {
    fetchUnprocessedEventModifiers(event.id!);
    List<EventModifier> eventModifiers = state.unprocessedEventModifiers;

    if (eventModifiers.isEmpty) {
      return event;
    }

    //patch atendees
    EventModifier? atendeesModifier;
    try {
      atendeesModifier = eventModifiers.firstWhere((modifier) => modifier.action == 'attendees/updateList');
    } catch (e) {
      print('No unprocessed EventModifier with attendees/updateList');
    }
    if (atendeesModifier != null) {
      List<EventAtendee> updatedAtendees = event.attendees!;

      List<dynamic> attendeeEmailsToAdd = atendeesModifier.content['attendeeEmailsToAdd'];
      List<dynamic> attendeeEmailsToRemove = atendeesModifier.content['attendeeEmailsToRemove'];

      if (attendeeEmailsToAdd.isNotEmpty) {
        for (var emailToAdd in attendeeEmailsToAdd) {
          updatedAtendees.add(EventAtendee(email: emailToAdd));
        }
      }
      if (attendeeEmailsToRemove.isNotEmpty) {
        for (var emailToRemove in attendeeEmailsToRemove) {
          updatedAtendees.removeWhere((atendee) => atendee.email == emailToRemove);
        }
      }
      event = event.copyWith(attendees: updatedAtendees);
    }

    //patch rsvp
    EventModifier? rsvpModifier;
    try {
      rsvpModifier = eventModifiers.firstWhere((modifier) => modifier.action == 'attendees/updateRsvp');
    } catch (e) {
      print('No unprocessed EventModifier with updateRsvp');
    }

    if (rsvpModifier != null) {
      List<EventAtendee> updatedAtendees = event.attendees!;
      EventAtendee loggedUser = event.attendees!.firstWhere((atendee) => atendee.email == event.originCalendarId);
      loggedUser = loggedUser.copyWith(responseStatus: rsvpModifier.content['responseStatus']);
      updatedAtendees.removeWhere((attendee) => attendee.email == event.originCalendarId);
      updatedAtendees.add(loggedUser);
      event = event.copyWith(attendees: updatedAtendees);
    }

    //patch conference
    EventModifier? removeConferenceModifier;
    EventModifier? addConferenceModifier;
    try {
      removeConferenceModifier = eventModifiers.firstWhere((modifier) => modifier.action == 'meeting/remove');
    } catch (e) {
      print('No unprocessed EventModifier with meeting/remove');
    }
    try {
      addConferenceModifier = eventModifiers.firstWhere((modifier) => modifier.action == 'meeting/add');
    } catch (e) {
      print('No unprocessed EventModifier with meeintg/add');
    }
    if (removeConferenceModifier != null && addConferenceModifier != null) {
      DateTime removeCreatedAt = DateTime.parse(removeConferenceModifier.createdAt!);
      DateTime addCreatedAt = DateTime.parse(addConferenceModifier.createdAt!);
      if (removeCreatedAt.isBefore(addCreatedAt)) {
        removeConferenceModifier = null;
      } else if (addCreatedAt.isBefore(removeCreatedAt)) {
        addConferenceModifier = null;
      }
    }
    if (removeConferenceModifier != null) {
      event = event.copyWith(meetingSolution: Nullable(null));
    }
    if (addConferenceModifier != null) {
      String meetingSolution = addConferenceModifier.content['meetingSolution'];
      event = event.copyWith(meetingSolution: Nullable(meetingSolution));
    }

    return event;
  }
}
