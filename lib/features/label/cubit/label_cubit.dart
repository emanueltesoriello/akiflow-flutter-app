import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

part 'label_state.dart';

class LabelCubit extends Cubit<LabelCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  LabelCubit(Label label) : super(LabelCubitState(selectedLabel: label)) {
    _init();
  }

  _init() async {
    List<Task> tasks = await _tasksRepository.getLabelTasks(state.selectedLabel!);
    emit(state.copyWith(tasks: tasks));
  }
}
