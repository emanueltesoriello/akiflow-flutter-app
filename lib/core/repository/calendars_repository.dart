import 'package:mobile/core/repository/database_repository.dart';

class CalendarsRepository extends DatabaseRepository {
  static const table = 'calendars';

  CalendarsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);
}
