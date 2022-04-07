import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/tasks.dart';
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
      List<Task> all = await _tasksRepository.all();

      emit(state.copyWith(tasks: all));
    }
  }

  void loggedEvent() {
    _init();
  }

  void firstLoginEvent() {
    _init();
  }
}
