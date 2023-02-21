import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/contacts_repository.dart';
import 'package:mobile/core/repository/event_modifiers_repository.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:models/contact/contact.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_modifier.dart';
import 'package:uuid/uuid.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsCubitState> {
  EventsCubit(this._syncCubit) : super(const EventsCubitState());

  final EventsRepository _eventsRepository = locator<EventsRepository>();
  final EventModifiersRepository _eventModifiersRepository = locator<EventModifiersRepository>();
  final ContactsRepository _contactsRepository = locator<ContactsRepository>();
  final SyncCubit _syncCubit;

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
    if (addMeeting) {
      await _eventModifiersRepository.add([addMeetingEventModifier(event)]);
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
    EventModifier eventModifier = EventModifier(
        id: const Uuid().v4(),
        akiflowAccountId: event.akiflowAccountId,
        eventId: event.id,
        calendarId: event.calendarId,
        action: 'meeting/add',
        content: {
          "meetingSolution": "meet",
        },
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
        content: {},
        createdAt: DateTime.now().toUtc().toIso8601String());
    return eventModifier;
  }
}
