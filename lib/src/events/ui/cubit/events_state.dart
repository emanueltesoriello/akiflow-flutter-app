part of 'events_cubit.dart';

class EventsCubitState extends Equatable {
  final List<Event> events;
  final List<Contact> searchedContacts;
  final List<EventModifier> unprocessedEventModifiers;

  const EventsCubitState({
    this.events = const [],
    this.searchedContacts = const [],
    this.unprocessedEventModifiers = const [],
  });

  EventsCubitState copyWith({
    List<Event>? events,
    List<Contact>? searchedContacts,
    List<EventModifier>? unprocessedEventModifiers,
  }) {
    return EventsCubitState(
      events: events ?? this.events,
      searchedContacts: searchedContacts ?? this.searchedContacts,
      unprocessedEventModifiers: unprocessedEventModifiers ?? this.unprocessedEventModifiers,
    );
  }

  @override
  List<Object?> get props => [events, searchedContacts, unprocessedEventModifiers];
}
