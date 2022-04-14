import 'package:mobile/repository/database_repository.dart';

class TasksRepository extends DatabaseRepository {
  static const table = 'tasks';

  TasksRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  @override
  Future<List<Task>> get<Task>() async {
    return await super.get<Task>();
  }

  @override
  Future<void> add<Task>(List<Task> items) async {
    await super.add<Task>(items);
  }

  @override
  Future<void> updateById<Task>(String? id, {required Task data}) async {
    await super.updateById<Task>(id, data: data);
  }

  @override
  Future<List<Task>> unsynced<Task>() async {
    return await super.unsynced<Task>();
  }

  @override
  Future<Task> byId<Task>(String id) async {
    return await super.byId<Task>(id);
  }
}
