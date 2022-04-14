import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/event/event.dart';

class EventApi extends Api {
  EventApi()
      : super(
          Uri.parse(Config.endpoint + "/v3/events"),
          fromMap: Event.fromMap,
        );

  @override
  Future<List<Event>> get<Event>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = false,
  }) async {
    return await super.get<Event>(
      perPage: perPage,
      withDeleted: withDeleted,
      updatedAfter: updatedAfter,
      allPages: allPages,
    );
  }

  @override
  Future<List<Event>> post<Event>({required List<Event> unsynced}) async {
    return (await super.post(
      unsynced: unsynced,
    ));
  }
}
