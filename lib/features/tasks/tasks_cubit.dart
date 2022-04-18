import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  TasksCubit() : super(const TasksCubitState());

  _init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      List<Task> all = await _tasksRepository.get();

      emit(state.copyWith(tasks: all));
    }
  }

  void logout() {
    emit(state.copyWith(tasks: []));
  }

  void refresh() {
    _init();
  }

  void setCompleted(Task task) {
    int index = state.tasks.indexOf(task);

    DateTime? now = DateTime.now().toUtc();

    task = task.rebuild(
      (b) => b
        ..done = true
        ..doneAt = now
        ..status = TaskStatusType.completed.id
        ..updatedAt = now,
    );

    List<Task> all = state.tasks.toList();

    all[index] = task;

    emit(state.copyWith(tasks: all));

    _tasksRepository.updateById(task.id, data: task);
  }
}
