part of 'events_cubit.dart';

class EventsCubitState extends Equatable {
  final List<Event> events;

  const EventsCubitState({this.events = const []});

  EventsCubitState copyWith({List<Event>? events}) {
    return EventsCubitState(events: events ?? this.events);
  }

  @override
  List<Object?> get props => [events];
}
