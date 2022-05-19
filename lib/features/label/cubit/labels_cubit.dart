import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';

part 'labels_state.dart';

class LabelsCubit extends Cubit<LabelsCubitState> {
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  final TasksCubit tasksCubit;

  LabelsCubit(this.tasksCubit) : super(const LabelsCubitState()) {
    _init();
  }

  _init() async {
    await syncAllAndRefresh();
  }

  Future<void> addLabel(Label newLabel) async {
    User user = _preferencesRepository.user!;

    newLabel = newLabel.copyWith(userId: user.id);

    List<Label> labels = List.from(state.labels);
    labels.add(newLabel);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.add([newLabel]);

    await _syncControllerService.syncAll();
  }

  Future<void> updateLabel(Label label) async {
    List<Label> labels = List.from(state.labels);

    int index = labels.indexWhere((l) => l.id == label.id);

    labels[index] = label;

    emit(state.copyWith(labels: labels));

    await _labelsRepository.updateById(label.id, data: label);

    await syncAllAndRefresh();
  }

  Future<void> addSectionToDatabase(Label newSection) async {
    User user = _preferencesRepository.user!;

    newSection = newSection.copyWith(userId: user.id);

    List<Label> labels = List.from(state.labels);
    labels.add(newSection);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.add([newSection]);

    await _syncControllerService.syncAll();

    await _init();
  }

  Future<void> syncAllAndRefresh({bool loading = false}) async {
    emit(state.copyWith(loading: loading ? true : state.loading));

    await _syncControllerService.syncAll();

    await fetchLabels();

    emit(state.copyWith(loading: false));
  }

  Future<void> fetchLabelTasks(Label? selectedLabel) async {
    List<Task> tasks = await _tasksRepository.getLabelTasks(selectedLabel!);
    tasksCubit.emit(tasksCubit.state.copyWith(labelTasks: tasks));
  }

  Future<void> fetchLabels() async {
    List<Label> labels = await _labelsRepository.get();
    emit(state.copyWith(labels: labels));
  }

  void updateUiAfterDeleteSection(Label section) {
    List<Task> labelTasks = tasksCubit.state.labelTasks.toList();

    for (Task task in labelTasks) {
      if (task.sectionId == section.id) {
        task = task.copyWith(sectionId: Nullable(null), listId: section.parentId);
        tasksCubit.updateUiOfTask(task);
      }
    }
  }
}
