import 'package:mobile/repository/database_repository.dart';

class LabelsRepository extends DatabaseRepository {
  static const table = 'lists';

  LabelsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);
}
