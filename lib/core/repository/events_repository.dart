import 'package:mobile/core/repository/database_repository.dart';

class EventsRepository extends DatabaseRepository {
  static const table = 'events';

  EventsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);
}
