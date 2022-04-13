import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/task/task.dart';

class TaskApi extends Api {
  TaskApi()
      : super(
          Uri.parse(Config.endpoint + "/v2/tasks"),
          fromMap: Task.fromMap,
        );

  @override
  Future<List<Task>> get<Task>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = false,
  }) async {
    return await super.get<Task>(
      perPage: perPage,
      withDeleted: withDeleted,
      updatedAfter: updatedAfter,
      allPages: allPages,
    );
  }

  @override
  Future<List<Task>> post<Task>({required List<Task> unsynced}) async {
    return (await super.post(
      unsynced: unsynced,
    ));
  }
}
