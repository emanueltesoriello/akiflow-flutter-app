import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/tasks_repository.dart';
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

  void logoutEvent() {
    emit(state.copyWith(tasks: []));
  }

  void refresh() {
    _init();
  }

  void setCompleted(Task task) {
    // TESTING
    task = task.rebuild(
      (b) => b
        ..title = "Sync 10 OK"
        ..updatedAt = DateTime.now(),
    );

    _tasksRepository.updateById(task.id, data: task);
  }
}
