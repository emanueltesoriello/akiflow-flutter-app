import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/task/task.dart';

class TaskApi extends ApiClient {
  TaskApi()
      : super(
          Uri.parse("${Config.endpoint}/v3/tasks"),
          fromMap: Task.fromMap,
        );
}
