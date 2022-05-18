import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:uuid/uuid.dart';

part 'label_state.dart';

class LabelCubit extends Cubit<LabelCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  final LabelsCubit labelsCubit;

  LabelCubit(Label label, {required this.labelsCubit}) : super(LabelCubitState(selectedLabel: label)) {
    _init();
  }

  _init() async {
    List<Task> tasks = await _tasksRepository.getLabelTasks(state.selectedLabel!);
    emit(state.copyWith(tasks: tasks));
  }

  void setColor(String rawColorName) {
    Label label = state.selectedLabel!.copyWith(color: rawColorName);
    emit(state.copyWith(selectedLabel: label));
  }

  void setFolder(Label folder) {
    Label label = state.selectedLabel!.copyWith(parentId: folder.id);
    emit(state.copyWith(selectedLabel: label));
  }

  void saveLabel(Label label) {
    if (state.selectedLabel?.id == null) {
      Label newLabel = label.copyWith(id: const Uuid().v4());
      labelsCubit.addLabel(newLabel);
    } else {
      label = label.copyWith(updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));
      labelsCubit.updateLabel(label);
      emit(state.copyWith(selectedLabel: label));
    }
  }

  void titleChanged(String value) {
    Label label = state.selectedLabel!.copyWith(title: value);
    emit(state.copyWith(selectedLabel: label));
  }

  void createFolder() {
    Label newLabel = state.selectedLabel!.copyWith(id: const Uuid().v4(), type: "folder");
    labelsCubit.addLabel(newLabel);
  }
}
