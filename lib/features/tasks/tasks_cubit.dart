import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';
import 'package:uuid/uuid.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  final SyncControllerService _syncControllerService =
      locator<SyncControllerService>();

  TasksCubit() : super(const TasksCubitState()) {
    refresh();
  }

  refresh() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      await _syncControllerService.sync();

      List<Task> all = await _tasksRepository.get();

      emit(state.copyWith(tasks: all));
    }
  }

  void logout() {
    emit(state.copyWith(tasks: []));
  }

  Future<void> setCompleted(Task task) async {
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

    await _tasksRepository.updateById(task.id, data: task);

    await _syncControllerService.sync();

    refresh();
  }

  Future<void> addTask(Task task) async {
    DateTime? now = DateTime.now().toUtc();

    task = task.rebuild(
      (b) => b
        ..id = const Uuid().v4()
        ..updatedAt = now
        ..createdAt = now,
    );

    List<Task> all = state.tasks.toList();

    all.add(task);

    emit(state.copyWith(tasks: all));

    await _tasksRepository.add([task]);

    await _syncControllerService.sync();

    refresh();
  }
}
