import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:models/task/task.dart';

part 'someday_state.dart';

class SomedayCubit extends Cubit<SomedayCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  SomedayCubit() : super(const SomedayCubitState()) {
    _init();
  }

  _init() async {
    List<Task> tasks = await _tasksRepository.getSomeday();
    emit(state.copyWith(tasks: tasks));
  }
}
