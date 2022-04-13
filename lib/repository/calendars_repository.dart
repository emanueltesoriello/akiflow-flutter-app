import 'package:mobile/repository/database_repository.dart';
import 'package:sqflite/sqflite.dart';

class CalendarsRepository extends DatabaseRepository {
  static const table = 'calendars';

  CalendarsRepository(
    Database database, {
    required Function(Map<String, dynamic>) fromSql,
  }) : super(database, tableName: table, fromSql: fromSql);

  @override
  Future<List<Calendar>> get<Calendar>() async {
    return await super.get<Calendar>();
  }

  @override
  Future<void> add<Calendar>(List<Calendar> items) async {
    await super.add<Calendar>(items);
  }

  @override
  Future<void> updateById<Calendar>(String? id,
      {required Calendar data}) async {
    await super.updateById<Calendar>(id, data: data);
  }

  @override
  Future<List<Calendar>> unsynced<Calendar>() async {
    return await super.unsynced<Calendar>();
  }

  @override
  Future<Calendar> byId<Calendar>(String id) async {
    return await super.byId<Calendar>(id);
  }
}
