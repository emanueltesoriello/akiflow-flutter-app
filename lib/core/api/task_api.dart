import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/task/task.dart';

class TaskApi extends ApiClient {
  TaskApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v3/tasks"),
          fromMap: Task.fromMap,
        );
}
