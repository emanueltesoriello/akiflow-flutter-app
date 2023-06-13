import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/contacts_repository.dart';
import 'package:mobile/core/repository/event_modifiers_repository.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/event_edit_modal.dart';
import 'package:mobile/src/events/ui/widgets/confirmation_modals/recurrent_event_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/contact/contact.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_atendee.dart';
import 'package:models/event/event_modifier.dart';
import 'package:models/nullable.dart';
import 'package:rrule/rrule.dart';
import 'package:uuid/uuid.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsCubitState> {
  final EventsRepository _eventsRepository = locator<EventsRepository>();
  final EventModifiersRepository _eventModifiersRepository = locator<EventModifiersRepository>();
  final ContactsRepository _contactsRepository = locator<ContactsRepository>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final SyncCubit _syncCubit;

  EventsCubit(this._syncCubit) : super(const EventsCubitState()) {
    _init();
  }

  _init() async {
    await fetchUnprocessedEventModifiers();

    _syncCubit.syncCompletedStream.listen((_) async {
      await fetchUnprocessedEventModifiers();
    });
  }

  Future<void> fetchEvents() async {
    try {
      List<Event> events = await _eventsRepository.getEvents();
      emit(state.copyWith(events: events));
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchEventsBetweenDates(DateTime start, DateTime end) async {
    try {
      List<Event> events = await _eventsRepository.getEventsBetweenDates(start, end);
      emit(state.copyWith(events: events));
    } catch (e) {
      print(e);
    }
  }

  resetEvents() {
    emit(state.copyWith(events: []));
  }

  Future<void> fetchSearchedContacts(String query) async {
    List<Contact> searchedContacts = await _contactsRepository.getSearchedContacts(query);
    if (searchedContacts.isEmpty) {
      searchedContacts.add(Contact(name: query, identifier: query));
    }
    emit(state.copyWith(searchedContacts: searchedContacts));
  }

  void refetchEvent(Event updatedEvent) async {
    Event fetchedEvent = await _eventsRepository.getById(updatedEvent.id);
    emit(state.copyWith(
      events: state.events.map((event) => event.id == updatedEvent.id ? fetchedEvent : event).toList(),
    ));
  }

  Future<void> refreshAllEvents(BuildContext context) async {
    CalendarCubit calendarCubit = context.read<CalendarCubit>();
    fetchEvents();
    Future.delayed(
      const Duration(milliseconds: 1200),
      () {
        fetchEventsBetweenDates(calendarCubit.state.visibleDates.first.subtract(const Duration(days: 1)),
            calendarCubit.state.visibleDates.last.add(const Duration(days: 1)));
      },
    );
  }

  void saveToStatePatchedEvent(Event patchedEvent) {
    emit(state.copyWith(
      events: state.events.map((event) => event.id == patchedEvent.id ? patchedEvent : event).toList(),
    ));
  }

  Future<void> scheduleEventsSync() async {
    Future.delayed(const Duration(seconds: 5))
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

  //START create Event section
  Future<void> addEventToDb(Event event) async {
    await _eventsRepository.add([event]);
  }

  Future<void> createEvent(BuildContext context, int duration, {DateTime? tappedTime}) async {
    String description = generateAkiflowSignature(context);
    CalendarCubit calendarCubit = context.read<CalendarCubit>();
    Calendar calendar = calendarCubit.state.calendars.firstWhere((calendar) => calendar.akiflowPrimary == true);
    var id = const Uuid().v4();
    DateTime startTime;
    DateTime now = DateTime.now();
    List<DateTime> visibleDates = calendarCubit.state.visibleDates;

    if (tappedTime != null) {
      startTime = tappedTime;
    } else if (visibleDates.isNotEmpty && visibleDates.length < 2) {
      startTime = DateTime(visibleDates.first.year, visibleDates.first.month, visibleDates.first.day, now.hour,
          [0, 15, 30, 45, 60][(now.minute / 15).ceil()]);
    } else {
      startTime = DateTime(now.year, now.month, now.day, now.hour, [0, 15, 30, 45, 60][(now.minute / 15).ceil()]);
    }

    String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    Event event = Event(
      id: id,
      creatorId: calendar.originId,
      organizerId: calendar.originId,
      calendarId: calendar.id,
      originCalendarId: calendar.originId,
      connectorId: calendar.connectorId,
      akiflowAccountId: calendar.akiflowAccountId,
      originAccountId: calendar.originAccountId,
      calendarColor: calendar.color,
      description: description,
      content: {"transparency": "opaque", "visibility": "default", "location": null},
      startDatetimeTz: currentTimeZone,
      startTime: TzUtils.toUtcStringIfNotNull(startTime),
      endTime: TzUtils.toUtcStringIfNotNull(startTime.add(Duration(seconds: duration))),
      createdAt: TzUtils.toUtcStringIfNotNull(now),
    );

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => EventEditModal(
        event: event,
        tappedDate: now,
        originalStartTime: now.toIso8601String(),
        createingEvent: true,
      ),
    ).whenComplete(() => refreshAllEvents(context));
  }

  String generateAkiflowSignature(BuildContext context) {
    String akiflowUrl =
        'https://akiflow.com/?utm_source=akiflow-calendar&utm_medium=akiflow-calendar&utm_campaign=akiflow-calendar';
    bool showAkiflowSignature = true;
    if (context.read<AuthCubit>().state.user?.settings?["general"] != null &&
        context.read<AuthCubit>().state.user?.settings?["general"]["showAkiflowSignature"] != null) {
      showAkiflowSignature = context.read<AuthCubit>().state.user?.settings?["general"]["showAkiflowSignature"];
    }

    if (showAkiflowSignature && context.read<AuthCubit>().state.user?.referralUrl != null) {
      var referral = context.read<AuthCubit>().state.user?.referralUrl;
      akiflowUrl = '$referral&utm_source=akiflow-calendar&utm_medium=akiflow-calendar&utm_campaign=akiflow-calendar';
    }
    if (showAkiflowSignature) {
      return '<br /><br />Scheduled with <a href="$akiflowUrl" target="_blank">Akiflow</a>';
    }
    return '';
  }
  //END create Event section

  //START update Event section

  ///updates response status of the user
  Future<void> updateAtend({required Event event, required String response, bool updateParent = false}) async {
    await _eventModifiersRepository.add([responseStatusEventModifier(event, response)]);

    if (updateParent) {
      await _eventModifiersRepository.add([responseStatusEventModifier(event, response, updateParent: true)]);
    }
    await _syncCubit.sync(entities: [Entity.events, Entity.eventModifiers]);
    await scheduleEventsSync();
    refetchEvent(event);

    AnalyticsService.track("Edit Event", properties: {
      "mobile": true,
      "mode": "click",
      "origin": "eventModal",
      "eventId": event.id,
      "eventRecurringId": event.recurringId,
    });
  }

  ///main method for updateing Event
  Future<void> updateEventAndCreateModifiers({
    required Event event,
    required List<String> atendeesToAdd,
    required List<String> atendeesToRemove,
    required bool addMeeting,
    required bool removeMeeting,
    bool createingEvent = false,
    bool dragAndDrop = false,
    String? selectedMeetingSolution,
    String? conferenceAccountId,
  }) async {
    if (atendeesToAdd.isNotEmpty || atendeesToRemove.isNotEmpty) {
      await _eventModifiersRepository.add([
        updateAtendeesEventModifier(event: event, atendeesToAdd: atendeesToAdd, atendeesToRemove: atendeesToRemove)
      ]);
    }
    if (addMeeting || (event.meetingUrl == null && atendeesToAdd.isNotEmpty)) {
      await _eventModifiersRepository
          .add([addMeetingEventModifier(event, selectedMeetingSolution, conferenceAccountId)]);
    }
    if (removeMeeting) {
      await _eventModifiersRepository.add([removeMeetingEventModifier(event)]);
    }
    await _eventsRepository.updateById(event.id, data: event);
    await _syncCubit.sync(entities: [Entity.events, Entity.eventModifiers]);
    await scheduleEventsSync();
    refetchEvent(event);

    AnalyticsService.track(
        createingEvent == true
            ? 'New Event'
            : dragAndDrop
                ? "Event Rescheduled"
                : 'Edit Event',
        properties: {
          "mobile": true,
          "mode": dragAndDrop ? "DragAndDrop" : "click",
          "origin": dragAndDrop ? "calendar" : "eventModal",
          "eventId": event.id,
          "eventRecurringId": event.recurringId,
        });
  }

  ///update method for case user selects "All Events" from an exception-event
  Future<void> updateParentAndExceptions({
    required Event exceptionEvent,
    required List<String> atendeesToAdd,
    required List<String> atendeesToRemove,
    required bool addMeeting,
    required bool removeMeeting,
    String? selectedMeetingSolution,
    String? conferenceAccountId,
    bool dragAndDrop = false,
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
        removeMeeting: removeMeeting,
        selectedMeetingSolution: selectedMeetingSolution,
        conferenceAccountId: conferenceAccountId,
        dragAndDrop: dragAndDrop);
    updateEventAndCreateModifiers(
        event: exceptionEvent.copyWith(updatedAt: Nullable(now)),
        atendeesToAdd: atendeesToAdd,
        atendeesToRemove: atendeesToRemove,
        addMeeting: addMeeting,
        removeMeeting: removeMeeting,
        selectedMeetingSolution: selectedMeetingSolution,
        conferenceAccountId: conferenceAccountId,
        dragAndDrop: dragAndDrop);
  }

  ///creates exception-Event for "Only this" option. Used to create and delete exception.
  Future<Event?> createEventException(
      {required BuildContext context,
      required DateTime tappedDate,
      required Event parentEvent,
      required bool dateChanged,
      required bool timeChanged,
      required List<String> atendeesToAdd,
      required List<String> atendeesToRemove,
      required bool addMeeting,
      required bool removeMeeting,
      required bool rsvpChanged,
      String? selectedMeetingSolution,
      String? conferenceAccountId,
      String? rsvpResponse,
      bool deleteEvent = false,
      bool dragAndDrop = false,
      String? originalStartTime}) async {
    String now = DateTime.now().toUtc().toIso8601String();

    DateTime? eventStartTime = parentEvent.startTime != null ? DateTime.parse(parentEvent.startTime!).toLocal() : null;
    DateTime? eventEndTime = parentEvent.endTime != null ? DateTime.parse(parentEvent.endTime!).toLocal() : null;

    String? startTime = eventStartTime != null
        ? timeChanged
            ? DateTime(tappedDate.year, tappedDate.month, tappedDate.day, eventStartTime.hour, eventStartTime.minute,
                    eventStartTime.second)
                .toUtc()
                .toIso8601String()
            : parentEvent.startTime
        : null;

    String? endTime = eventEndTime != null
        ? timeChanged
            ? DateTime(tappedDate.year, tappedDate.month, tappedDate.day, eventEndTime.hour, eventEndTime.minute,
                    eventEndTime.second)
                .toUtc()
                .toIso8601String()
            : parentEvent.endTime
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
      recurringException = prepareEventToDelete(recurringException).copyWith(updatedAt: Nullable(now), deletedAt: now);
    }

    await _eventsRepository.add([recurringException]);

    if (rsvpChanged && rsvpResponse != null) {
      updateAtend(event: recurringException, response: rsvpResponse).then((value) => refreshAllEvents(context));
    } else {
      updateEventAndCreateModifiers(
              event: recurringException,
              atendeesToAdd: atendeesToAdd,
              atendeesToRemove: atendeesToRemove,
              addMeeting: addMeeting,
              removeMeeting: removeMeeting,
              selectedMeetingSolution: selectedMeetingSolution,
              conferenceAccountId: conferenceAccountId,
              createingEvent: true,
              dragAndDrop: dragAndDrop)
          .then((value) => refreshAllEvents(context));
    }
    AnalyticsService.track("Edit Event", properties: {
      "mobile": true,
      "mode": "click",
      "origin": "eventModal",
      "eventId": parentEvent.id,
      "eventRecurringId": parentEvent.recurringId,
    });

    return recurringException;
  }

  ///update method for "This and future" option
  Future<Event?> updateThisAndFuture(
      {required DateTime tappedDate, required Event selectedEvent, String? response}) async {
    var id = const Uuid().v4();
    String now = DateTime.now().toUtc().toIso8601String();

    DateTime? eventStartTime =
        selectedEvent.startTime != null ? DateTime.parse(selectedEvent.startTime!).toLocal() : null;
    String? originalStartTime = eventStartTime != null
        ? DateTime(tappedDate.year, tappedDate.month, tappedDate.day, eventStartTime.hour, eventStartTime.minute,
                eventStartTime.second, eventStartTime.millisecond)
            .toUtc()
            .toIso8601String()
        : null;

    DateTime? eventEndTime = selectedEvent.endTime != null ? DateTime.parse(selectedEvent.endTime!).toLocal() : null;
    String? originalEndTime = eventEndTime != null
        ? DateTime(tappedDate.year, tappedDate.month, tappedDate.day, eventEndTime.hour, eventEndTime.minute,
                eventEndTime.second, eventEndTime.millisecond)
            .toUtc()
            .toIso8601String()
        : null;

    String? originalStartDate =
        selectedEvent.startDate != null ? DateFormat("y-MM-dd").format(tappedDate.toUtc()) : null;
    String? originalEndDate = selectedEvent.endDate != null ? DateFormat("y-MM-dd").format(tappedDate.toUtc()) : null;

    Event newParent = selectedEvent.copyWith(
      id: id,
      recurringId: id,
      recurrence: Nullable(selectedEvent.computeRuleForThisAndFuture()),
      startTime: Nullable(originalStartTime),
      endTime: Nullable(originalEndTime),
      startDate: Nullable(originalStartDate),
      endDate: Nullable(originalEndDate),
      originId: Nullable(null),
      customOriginId: Nullable(null),
      untilDatetime: Nullable(null),
      url: Nullable(null),
      updatedAt: Nullable(now),
    );
    await _eventsRepository.add([newParent]);

    if (newParent.attendees != null) {
      List<String> atendeesToAdd = newParent.attendees!.map((atendee) => atendee.email!).toList();
      await _eventModifiersRepository
          .add([updateAtendeesEventModifier(event: newParent, atendeesToAdd: atendeesToAdd, atendeesToRemove: [])]);
    }
    if (newParent.meetingUrl != null && newParent.meetingSolution != null) {
      _eventModifiersRepository.add([newParentMeetingEventModifier(newParent)]);
    }
    if (response != null) {
      EventModifier eventModifier = EventModifier(
          id: const Uuid().v4(),
          akiflowAccountId: newParent.akiflowAccountId,
          eventId: newParent.id,
          calendarId: newParent.calendarId,
          action: 'attendees/updateRsvp',
          content: {"responseStatus": response},
          createdAt: DateTime.now().toUtc().toIso8601String());

      await _eventModifiersRepository.add([eventModifier]);
    }

    endParentAtSelectedEvent(tappedDate: tappedDate, selectedEvent: selectedEvent);

    AnalyticsService.track("New Event", properties: {
      "mobile": true,
      "mode": "click",
      "origin": "eventModal",
      "eventId": newParent.id,
      "eventRecurringId": newParent.recurringId,
    });

    return newParent;
  }

  ///Used for "This and future" option. It ends the original parent at the selected date
  Future<void> endParentAtSelectedEvent({required DateTime tappedDate, required Event selectedEvent}) async {
    Event parentEvent = await _eventsRepository.getById(selectedEvent.recurringId);
    String now = DateTime.now().toUtc().toIso8601String();

    DateTime oldParenUntil = DateTime(tappedDate.year, tappedDate.month, tappedDate.day - 1, 23, 59, 59).toUtc();

    String processedRrule = '';
    processedRrule = parentEvent.computeRuleForThisAndFuture().first;

    RecurrenceRule parentRrule = RecurrenceRule.fromString(processedRrule);
    String newParenRrule = parentRrule.copyWith(clearCount: true, until: oldParenUntil).toString();

    List<String> parts = newParenRrule.split(";");
    String untilString = parts.where((part) => part.startsWith('UNTIL')).first;
    if (!untilString.endsWith('Z')) {
      parts.removeWhere((part) => part.startsWith('UNTIL'));
      untilString = '${untilString}Z';
      parts.add(untilString);
    }
    newParenRrule = parts.join(";");

    parentEvent = parentEvent.copyWith(
        recurrence: Nullable([newParenRrule]),
        untilDatetime: Nullable(oldParenUntil.toIso8601String()),
        updatedAt: Nullable(now));

    await _eventsRepository.updateById(parentEvent.id, data: parentEvent);
    deleteExceptionsByRecurringId(parentEvent.recurringId!, startingFrom: tappedDate.add(const Duration(days: 1)));
    await _syncCubit.sync(entities: [Entity.events, Entity.eventModifiers]);
    await scheduleEventsSync();

    AnalyticsService.track("Edit Event", properties: {
      "mobile": true,
      "mode": "click",
      "origin": "eventModal",
      "eventId": parentEvent.id,
      "eventRecurringId": parentEvent.recurringId,
    });
  }

  ///deletes all exception-events by recurrindId
  Future<void> deleteExceptionsByRecurringId(String recurringId, {bool sync = false, DateTime? startingFrom}) async {
    List<Event> exceptions = await _eventsRepository.getExceptionsByRecurringId(recurringId);
    String now = DateTime.now().toUtc().toIso8601String();
    if (exceptions.isNotEmpty) {
      if (startingFrom != null) {
        exceptions = exceptions
            .where((exception) => DateTime.parse(exception.startTime ?? exception.startDate!).isAfter(startingFrom))
            .toList();
      }
      for (var exception in exceptions) {
        exception = prepareEventToDelete(exception).copyWith(
          updatedAt: Nullable(now),
          deletedAt: now,
        );
        await _eventsRepository.updateById(exception.id, data: exception);
      }
    }

    if (sync) {
      await _syncCubit.sync(entities: [Entity.events]);
    }
  }
  //END update Event section

  //START delete Event section
  Future<void> deleteEvent(Event event, {bool deleteExceptions = false}) async {
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

    if (deleteExceptions) {
      deleteExceptionsByRecurringId(event.recurringId!);
    }

    entitiesToSync.add(Entity.events);

    _syncCubit.sync(entities: entitiesToSync);

    AnalyticsService.track("Event deleted", properties: {
      "mobile": true,
      "mode": "click",
      "origin": "eventModal",
      "eventId": event.id,
      "eventRecurringId": event.recurringId,
    });
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
  //END delete Event section

  //START drag and drop section

  ///handle drag&drop for a recurring Event
  Future<void> showRecurrenceEditModalDragAndDrop(
      {required BuildContext context, required Event event, required DateTime droppedTimeRounded}) async {
    DateTime? eventStartTime = event.startTime != null ? DateTime.parse(event.startTime!).toLocal() : null;
    String? originalStartTime = eventStartTime != null
        ? DateTime(droppedTimeRounded.year, droppedTimeRounded.month, droppedTimeRounded.day, eventStartTime.hour,
                eventStartTime.minute, eventStartTime.second, eventStartTime.millisecond)
            .toUtc()
            .toIso8601String()
        : null;

    await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => RecurrentEventEditModal(
              onlyThisTap: () {
                if (event.recurringId == event.id) {
                  Duration duration = const Duration(minutes: 30);
                  duration = DateTime.parse(event.endTime!).difference(DateTime.parse(event.startTime!));
                  event = event.copyWith(
                    startTime: Nullable(TzUtils.toUtcStringIfNotNull(droppedTimeRounded)),
                    endTime: Nullable(TzUtils.toUtcStringIfNotNull(droppedTimeRounded.add(duration))),
                    updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
                  );
                  createEventException(
                      context: context,
                      tappedDate: droppedTimeRounded,
                      dateChanged: false,
                      originalStartTime: originalStartTime,
                      timeChanged: true,
                      parentEvent: event,
                      atendeesToAdd: [],
                      atendeesToRemove: [],
                      addMeeting: false,
                      removeMeeting: false,
                      rsvpChanged: false,
                      dragAndDrop: true);
                } else {
                  updateEventFromCalendarDragAndDrop(event: event, droppedTimeRounded: droppedTimeRounded);
                }
              },
              thisAndFutureTap: () {
                event = prepareEventForDragAndDrop(event, droppedTimeRounded);
                if (event.startTime == originalStartTime) {
                  updateEventAndCreateModifiers(
                      event: event,
                      atendeesToAdd: [],
                      atendeesToRemove: [],
                      addMeeting: false,
                      removeMeeting: false,
                      dragAndDrop: true);
                } else {
                  context.read<EventsCubit>().updateThisAndFuture(tappedDate: droppedTimeRounded, selectedEvent: event);
                }
              },
              allTap: () {
                event = prepareEventForDragAndDrop(event, droppedTimeRounded);
                if (event.recurringId == event.id) {
                  updateEventAndCreateModifiers(
                      event: event,
                      atendeesToAdd: [],
                      atendeesToRemove: [],
                      addMeeting: false,
                      removeMeeting: false,
                      dragAndDrop: true);
                } else {
                  updateParentAndExceptions(
                      exceptionEvent: event,
                      atendeesToAdd: [],
                      atendeesToRemove: [],
                      addMeeting: false,
                      removeMeeting: false,
                      dragAndDrop: true);
                }
              },
            )).whenComplete(() => refreshAllEvents(context));
  }

  Future<void> updateEventFromCalendarDragAndDrop({required Event event, required DateTime droppedTimeRounded}) async {
    Duration duration = const Duration(minutes: 30);
    duration = DateTime.parse(event.endTime!).difference(DateTime.parse(event.startTime!));
    event = event.copyWith(
      startTime: Nullable(TzUtils.toUtcStringIfNotNull(droppedTimeRounded)),
      endTime: Nullable(TzUtils.toUtcStringIfNotNull(droppedTimeRounded.add(duration))),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );
    await _eventsRepository.updateById(event.id, data: event);
    refetchEvent(event);
    await _syncCubit.sync(entities: [Entity.events]);

    AnalyticsService.track("Event Rescheduled", properties: {
      "mobile": true,
      "mode": "DragAndDrop",
      "origin": "calendar",
      "eventId": event.id,
      "eventRecurringId": event.recurringId,
    });
  }

  Event prepareEventForDragAndDrop(Event event, DateTime droppedTimeRounded) {
    Duration duration = const Duration(minutes: 30);
    duration = DateTime.parse(event.endTime!).difference(DateTime.parse(event.startTime!));
    DateTime eventStartTime = DateTime.parse(event.startTime!);
    DateTime startTime = DateTime(eventStartTime.year, eventStartTime.month, eventStartTime.day,
        droppedTimeRounded.hour, droppedTimeRounded.minute, droppedTimeRounded.second);
    return event.copyWith(
      startTime: Nullable(TzUtils.toUtcStringIfNotNull(startTime)),
      endTime: Nullable(TzUtils.toUtcStringIfNotNull(startTime.add(duration))),
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );
  }
  //END drag and drop Event section

  //START event modifiers section

  ///creates EventModifier with responseStatus
  EventModifier responseStatusEventModifier(Event event, String response, {bool updateParent = false}) {
    EventModifier eventModifier = EventModifier(
        id: const Uuid().v4(),
        akiflowAccountId: event.akiflowAccountId,
        eventId: updateParent ? event.recurringId : event.id,
        calendarId: event.calendarId,
        action: 'attendees/updateRsvp',
        content: {"responseStatus": response},
        createdAt: DateTime.now().toUtc().toIso8601String());
    return eventModifier;
  }

  ///creates EventModifier for updating atendees
  EventModifier updateAtendeesEventModifier({
    required Event event,
    required List<String> atendeesToAdd,
    required List<String> atendeesToRemove,
  }) {
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
    return eventModifier;
  }

  ///creates EventModifier for new parent. For "This and future"-case
  EventModifier newParentMeetingEventModifier(Event newParent) {
    EventModifier eventModifier = EventModifier(
        id: const Uuid().v4(),
        akiflowAccountId: newParent.akiflowAccountId,
        eventId: newParent.id,
        calendarId: newParent.calendarId,
        action: 'meeting/add',
        content: {
          "meetingSolution": newParent.meetingSolution,
          "conferenceData": newParent.content["conferenceData"],
        },
        createdAt: DateTime.now().toUtc().toIso8601String());
    return eventModifier;
  }

  ///creates EventModifier for adding meeting
  EventModifier addMeetingEventModifier(Event event, String? selectedMeetingSolution, String? conferenceAccountId) {
    String meetingSolution = selectedMeetingSolution ?? getDefaultConferenceSolution();
    AuthCubit authCubit = locator<AuthCubit>();

    dynamic content;
    if (meetingSolution == 'zoom') {
      if (((conferenceAccountId != null && conferenceAccountId.isEmpty) || conferenceAccountId == null) &&
          authCubit.state.user?.settings?['calendar']['conferenceAccountId'] != null) {
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

  ///creates EventModifier for removing meeting
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
    DateTime? maxProcessedAtEvents = _preferencesRepository.lastEventsSyncAt;
    maxProcessedAtEvents ??= DateTime.now().toUtc();
    List<EventModifier> unprocessed =
        await _eventModifiersRepository.getUnprocessedEventModifiers(maxProcessedAtEvents.toIso8601String());
    emit(state.copyWith(unprocessedEventModifiers: unprocessed));
  }

  ///patches EventModifier data to Event
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
  //END event modifiers section
}
