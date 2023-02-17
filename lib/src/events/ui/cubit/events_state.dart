part of 'events_cubit.dart';

class EventsCubitState extends Equatable {
  final List<Event> events;
  final List<Contact> searchedContacts;

  const EventsCubitState({
    this.events = const [],
    this.searchedContacts = const [],
  });

  EventsCubitState copyWith({
    List<Event>? events,
    List<Contact>? searchedContacts,
  }) {
    return EventsCubitState(
      events: events ?? this.events,
      searchedContacts: searchedContacts ?? this.searchedContacts,
    );
  }

  @override
  List<Object?> get props => [events, searchedContacts];
}
