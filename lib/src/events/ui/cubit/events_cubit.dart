import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:models/event/event.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsCubitState> {
  EventsCubit(this._syncCubit) : super(const EventsCubitState()) {
    _init();
  }

  final EventsRepository _eventsRepository = locator<EventsRepository>();
  final SyncCubit _syncCubit;

  _init() {
    //fetchEvents();

    _syncCubit.syncCompletedStream.listen((_) async {
      //await fetchEvents();
    });
  }

  Future<void> fetchEvents() async {
    List<Event> events = await _eventsRepository.getEvents();
    emit(state.copyWith(events: events));
  }

  Future<void> fetchEventsBetweenDates(DateTime startTime, DateTime? endTime) async {
    List<Event> events = await _eventsRepository.getEventsBetweenDates(startTime, endTime);
    emit(state.copyWith(events: events));
  }

  Future<void> updateEvent(Event event) async {
    await _eventsRepository.updateById(event.id, data: event);

    await fetchEvents();

    _syncCubit.sync(entities: [Entity.events]);
  }
}
