import 'package:models/task/task.dart';

class GroupedTasks {
  final String id;
  List<Task> taskList;
  DateTime startTime;
  DateTime endTime;

  GroupedTasks(
    this.id,
    this.taskList,
    this.startTime,
    this.endTime,
  );

  @override
  String toString() {
    return 'GroupedTasks with tasks: $taskList';
  }
}
