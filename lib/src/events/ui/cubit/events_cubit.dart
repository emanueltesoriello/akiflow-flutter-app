import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
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

  EventsCubit(this._syncCubit) : super(const EventsCubitState()) {
    _init();
  }

  _init() async {
    await fetchUnprocessedEventModifiers();
  }

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
    Future.delayed(const Duration(seconds: 4))
        .whenComplete(() => _syncCubit.sync(entities: [Entity.events, Entity.eventModifiers]));
    Future.delayed(const Duration(seconds: 10))
        .whenComplete(() => _syncCubit.sync(entities: [Entity.events, Entity.eventModifiers]));
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

  //EventModifiers

  Future<void> updateAtend({required Event event, required String response, bool updateParent = false}) async {
    EventModifier eventModifier = EventModifier(
        id: const Uuid().v4(),
        akiflowAccountId: event.akiflowAccountId,
        eventId: event.id,
        calendarId: event.calendarId,
        action: 'attendees/updateRsvp',
        content: {"responseStatus": response},
        createdAt: DateTime.now().toUtc().toIso8601String());

    List<EventModifier> eventModifiersToSync = [eventModifier];

    if (updateParent) {
      EventModifier parentEventModifier = EventModifier(
          id: const Uuid().v4(),
          akiflowAccountId: event.akiflowAccountId,
          eventId: event.recurringId,
          calendarId: event.calendarId,
          action: 'attendees/updateRsvp',
          content: {"responseStatus": response},
          createdAt: DateTime.now().toUtc().toIso8601String());

      eventModifiersToSync.add(parentEventModifier);
    }

    await _eventModifiersRepository.add(eventModifiersToSync);
    refetchEvent(event);
    await _syncCubit.sync(entities: [Entity.events, Entity.eventModifiers]);
    await scheduleEventsSync();
    refetchEvent(event);
  }

  Future<void> updateEventAndCreateModifiers({
    required Event event,
    required List<String> atendeesToAdd,
    required List<String> atendeesToRemove,
    required bool addMeeting,
    required bool removeMeeting,
  }) async {
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
    if (addMeeting) {
      await _eventModifiersRepository.add([addMeetingEventModifier(event)]);
    }
    if (removeMeeting) {
      await _eventModifiersRepository.add([removeMeetingEventModifier(event)]);
    }
    await _eventsRepository.updateById(event.id, data: event);
    refetchEvent(event);
    await _syncCubit.sync(entities: [Entity.events, Entity.eventModifiers]);
    await scheduleEventsSync();
    refetchEvent(event);
  }

  Future<void> updateParentAndExceptions({
    required Event exceptionEvent,
    required List<String> atendeesToAdd,
    required List<String> atendeesToRemove,
    required bool addMeeting,
    required bool removeMeeting,
  }) async {
    Event parentEvent = await _eventsRepository.getById(exceptionEvent.recurringId);
    String now = DateTime.now().toUtc().toIso8601String();

    DateTime? parentStartTime = parentEvent.startTime != null ? DateTime.parse(parentEvent.startTime!).toLocal() : null;
    DateTime? exceptionStartTime =
        exceptionEvent.startTime != null ? DateTime.parse(exceptionEvent.startTime!).toLocal() : null;
    String? startTime = parentStartTime != null && exceptionStartTime != null
        ? DateTime(parentStartTime.year, parentStartTime.month, parentStartTime.day, exceptionStartTime.hour,
                exceptionStartTime.minute, exceptionStartTime.second, exceptionStartTime.millisecond)
            .toUtc()
            .toIso8601String()
        : null;

    DateTime? parentEndTime = parentEvent.endTime != null ? DateTime.parse(parentEvent.endTime!).toLocal() : null;
    DateTime? exceptionEndTime =
        exceptionEvent.endTime != null ? DateTime.parse(exceptionEvent.endTime!).toLocal() : null;
    String? endTime = parentEndTime != null && exceptionEndTime != null
        ? DateTime(parentEndTime.year, parentEndTime.month, parentEndTime.day, exceptionEndTime.hour,
                exceptionEndTime.minute, exceptionEndTime.second, exceptionEndTime.millisecond)
            .toUtc()
            .toIso8601String()
        : null;

    parentEvent = parentEvent.copyWith(
      title: Nullable(exceptionEvent.title),
      description: Nullable(exceptionEvent.description),
      startTime: Nullable(startTime),
      endTime: Nullable(endTime),
      color: exceptionEvent.color,
      meetingIcon: Nullable(exceptionEvent.meetingIcon),
      meetingSolution: Nullable(exceptionEvent.meetingSolution),
      meetingStatus: Nullable(exceptionEvent.meetingStatus),
      meetingUrl: Nullable(exceptionEvent.meetingUrl),
      content: exceptionEvent.content,
      attendees: Nullable(exceptionEvent.attendees),
      updatedAt: Nullable(now),
    );

    updateEventAndCreateModifiers(
        event: parentEvent,
        atendeesToAdd: atendeesToAdd,
        atendeesToRemove: atendeesToRemove,
        addMeeting: addMeeting,
        removeMeeting: removeMeeting);
    updateEventAndCreateModifiers(
        event: exceptionEvent.copyWith(updatedAt: Nullable(now)),
        atendeesToAdd: atendeesToAdd,
        atendeesToRemove: atendeesToRemove,
        addMeeting: addMeeting,
        removeMeeting: removeMeeting);
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

  Future<void> fetchUnprocessedEventModifiers() async {
    List<EventModifier> unprocessed = await _eventModifiersRepository.getUnprocessedEventModifiers();
    emit(state.copyWith(unprocessedEventModifiers: unprocessed));
  }

  Event patchEventWithEventModifier(Event event) {
    List<EventModifier> eventModifiers = state.unprocessedEventModifiers
        .where((modifier) => modifier.eventId == event.id && modifier.attempts == null)
        .toList();

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
      List<EventAtendee>? updatedAtendees = event.attendees;

      List<dynamic> attendeeEmailsToAdd = atendeesModifier.content['attendeeEmailsToAdd'];
      List<dynamic> attendeeEmailsToRemove = atendeesModifier.content['attendeeEmailsToRemove'];

      if (attendeeEmailsToAdd.isNotEmpty) {
        if (updatedAtendees == null || updatedAtendees.isEmpty) {
          updatedAtendees = List.empty(growable: true);
        }
        for (var emailToAdd in attendeeEmailsToAdd) {
          updatedAtendees.add(EventAtendee(email: emailToAdd));
        }
      }
      if (attendeeEmailsToRemove.isNotEmpty && updatedAtendees != null) {
        for (var emailToRemove in attendeeEmailsToRemove) {
          updatedAtendees.removeWhere((atendee) => atendee.email == emailToRemove);
        }
      }
      event = event.copyWith(attendees: Nullable(updatedAtendees));
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
      event = event.copyWith(attendees: Nullable(updatedAtendees));
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

  //create event exception

  Future<void> createEventException(
      {required DateTime tappedDate,
      required Event parentEvent,
      required bool dateChanged,
      required bool timeChanged,
      required List<String> atendeesToAdd,
      required List<String> atendeesToRemove,
      required bool addMeeting,
      required bool removeMeeting,
      required bool rsvpChanged,
      String? rsvpResponse,
      bool deleteEvent = false,
      String? originalStartTime}) async {
    String now = DateTime.now().toUtc().toIso8601String();

    DateTime? eventStartTime = parentEvent.startTime != null ? DateTime.parse(parentEvent.startTime!).toLocal() : null;
    DateTime? eventEndTime = parentEvent.endTime != null ? DateTime.parse(parentEvent.endTime!).toLocal() : null;
    String? startTime = timeChanged
        ? parentEvent.startTime
        : eventStartTime != null
            ? DateTime(tappedDate.year, tappedDate.month, tappedDate.day, eventStartTime.hour, eventStartTime.minute,
                    eventStartTime.second)
                .toUtc()
                .toIso8601String()
            : null;
    String? endTime = timeChanged
        ? parentEvent.endTime
        : eventEndTime != null
            ? DateTime(tappedDate.year, tappedDate.month, tappedDate.day, eventEndTime.hour, eventEndTime.minute,
                    eventEndTime.second)
                .toUtc()
                .toIso8601String()
            : null;

    String? startDate = parentEvent.startDate != null
        ? dateChanged
            ? parentEvent.startDate
            : DateFormat("y-MM-dd").format(tappedDate.toUtc())
        : null;
    String? endDate = parentEvent.endDate != null
        ? dateChanged
            ? parentEvent.endDate
            : DateFormat("y-MM-dd").format(tappedDate.toUtc())
        : null;

    Event recurringException = parentEvent.copyWith(
      id: const Uuid().v4(),
      recurrenceException: true,
      hidden: false,
      startDate: Nullable(startDate),
      endDate: Nullable(endDate),
      startTime: Nullable(startTime),
      endTime: Nullable(endTime),
      originalStartDate:
          Nullable(parentEvent.startDate != null ? DateFormat("y-MM-dd").format(tappedDate.toUtc()) : null),
      originalStartTime: Nullable(originalStartTime),
      createdAt: now,
      updatedAt: Nullable(now),
      originId: Nullable(null),
      customOriginId: Nullable(null),
      originRecurringId: parentEvent.originId,
      originUpdatedAt: Nullable(null),
      untilDatetime: Nullable(null),
      url: Nullable(null),
      remoteUpdatedAt: Nullable(null),
    );

    if (deleteEvent) {
      recurringException = prepareEventToDelete(recurringException);
    }

    await _eventsRepository.add([recurringException]);

    if (rsvpChanged && rsvpResponse != null) {
      updateAtend(event: recurringException, response: rsvpResponse);
    } else {
      updateEventAndCreateModifiers(
          event: recurringException,
          atendeesToAdd: atendeesToAdd,
          atendeesToRemove: atendeesToRemove,
          addMeeting: addMeeting,
          removeMeeting: removeMeeting);
    }
  }

  Future<void> deleteEvent(Event event) async {
    String now = DateTime.now().toUtc().toIso8601String();
    List<Entity> entitiesToSync = List.empty(growable: true);
    Event eventToDelete = prepareEventToDelete(event).copyWith(
      updatedAt: Nullable(now),
      deletedAt: now,
    );

    if (event.meetingUrl != null && event.recurringId != event.id) {
      await _eventModifiersRepository.add([removeMeetingEventModifier(event)]);
      entitiesToSync.add(Entity.eventModifiers);
    }

    await _eventsRepository.updateById(event.id, data: eventToDelete);
    entitiesToSync.add(Entity.events);

    _syncCubit.sync(entities: entitiesToSync);
  }

  Event prepareEventToDelete(Event event) {
    return event.copyWith(
      etag: Nullable(null),
      title: Nullable(null),
      description: Nullable(null),
      attendees: Nullable(null),
      recurrence: Nullable(null),
      url: Nullable(null),
      meetingIcon: Nullable(null),
      meetingSolution: Nullable(null),
      meetingStatus: Nullable(null),
      meetingUrl: Nullable(null),
      status: 'cancelled',
    );
  }
}
