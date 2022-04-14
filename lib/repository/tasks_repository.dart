import 'package:mobile/repository/database_repository.dart';

class TasksRepository extends DatabaseRepository {
  static const table = 'tasks';

  TasksRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);
}
