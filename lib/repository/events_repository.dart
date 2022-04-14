import 'package:mobile/repository/database_repository.dart';

class EventsRepository extends DatabaseRepository {
  static const table = 'events';

  EventsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  @override
  Future<List<Event>> get<Event>() async {
    return await super.get<Event>();
  }

  @override
  Future<void> add<Event>(List<Event> items) async {
    await super.add<Event>(items);
  }

  @override
  Future<void> updateById<Event>(String? id, {required Event data}) async {
    await super.updateById<Event>(id, data: data);
  }

  @override
  Future<List<Event>> unsynced<Event>() async {
    return await super.unsynced<Event>();
  }

  @override
  Future<Event> byId<Event>(String id) async {
    return await super.byId<Event>(id);
  }
}
