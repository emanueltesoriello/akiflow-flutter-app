import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:models/event/event.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsCubitState> {
  EventsCubit(this._syncCubit) : super(const EventsCubitState());

  final EventsRepository _eventsRepository = locator<EventsRepository>();
  final SyncCubit _syncCubit;

  Future<void> fetchEventsBetweenDates(String startDate, String endDate) async {
    List<Event> events = await _eventsRepository.getEventsBetweenDates(startDate, endDate);
    emit(state.copyWith(events: events));
  }

  Future<void> updateEvent(Event event) async {
    await _eventsRepository.updateById(event.id, data: event);
    refreshEventUi(event);
    _syncCubit.sync(entities: [Entity.events]);
  }

  void refreshEventUi(Event updatedEvent) {
    emit(state.copyWith(
      events: state.events.map((event) => event.id == updatedEvent.id ? updatedEvent : event).toList(),
    ));
  }
}
