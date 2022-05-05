import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:uuid/uuid.dart';

part 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final SyncControllerService _syncControllerService =
      locator<SyncControllerService>();

  final TasksCubit _tasksCubit;

  TaskStatusType? lastDoneTaskStatus;

  EditTaskCubit(this._tasksCubit, {Task? task})
      : super(
          EditTaskCubitState(
            newTask: task ??
                Task().rebuild(
                  (b) => b
                    ..id = const Uuid().v4()
                    ..status = TaskStatusType.inbox.id,
                ),
          ),
        ) {
    _init();
  }

  _init() async {}

  Future<void> create({
    required String title,
    required String description,
  }) async {
    DateTime? now = DateTime.now().toUtc();

    Task updated = state.newTask.rebuild(
      (b) => b
        ..title = title
        ..description = description
        ..updatedAt = now
        ..createdAt = now
        ..listId = state.selectedLabel?.id,
    );

    emit(state.copyWith(newTask: updated));

    List<Task> all = _tasksCubit.state.tasks.toList();

    all.add(updated);

    _tasksCubit.emit(_tasksCubit.state.copyWith(tasks: all));

    await _tasksRepository.add([updated]);

    await _syncControllerService.syncTasks();

    _tasksCubit.refreshTasks();
  }

  void selectPlanType(EditTaskPlanType type) {
    emit(state.copyWith(planType: type));
  }

  void planFor(DateTime date, {DateTime? dateTime}) {
    Task updated = state.newTask.rebuild(
      (b) => b
        ..date = date.toUtc()
        ..datetime = dateTime?.toUtc()
        ..status = state.planType == EditTaskPlanType.plan
            ? TaskStatusType.planned.id
            : TaskStatusType.snoozed.id,
    );

    emit(state.copyWith(newTask: updated));
  }

  void setForInbox() {
    Task updated = state.newTask.rebuild(
      (b) => b
        ..date = null
        ..status = TaskStatusType.inbox.id,
    );

    emit(state.copyWith(newTask: updated));
  }

  void setSomeday() {
    Task updated = state.newTask.rebuild(
      (b) => b
        ..date = null
        ..status = TaskStatusType.someday.id,
    );

    emit(state.copyWith(newTask: updated));
  }

  void selectDate(DateTime selectedDate) {
    emit(state.copyWith(selectedDate: selectedDate));
  }

  void setDuration(double value) {
    emit(state.copyWith(selectedDuration: value));

    double seconds = value * 3600;

    Task updated = state.newTask.rebuild((b) => b..duration = seconds.toInt());

    emit(state.copyWith(newTask: updated));
  }

  void toggleDuration() {
    emit(state.copyWith(setDuration: !state.setDuration));

    if (state.setDuration == false) {
      Task updated = state.newTask.rebuild((b) => b..duration = null);

      emit(state.copyWith(newTask: updated));
    }
  }

  void toggleLabels() {
    emit(state.copyWith(showLabelsList: !state.showLabelsList));
  }

  void setLabel(Label label) {
    Task updated = state.newTask.rebuild((b) => b..listId = label.id);

    emit(state.copyWith(
      selectedLabel: label,
      showLabelsList: false,
      newTask: updated,
    ));
  }

  void markAsDone(Task task) {
    bool done = task.isCompletedComputed;

    if (task.status != TaskStatusType.completed.id) {
      lastDoneTaskStatus = TaskStatusTypeExt.fromId(task.status);
    }

    DateTime? now = DateTime.now().toUtc();

    if (!done) {
      task = task.rebuild(
        (b) => b
          ..done = true
          ..doneAt = now
          ..updatedAt = now
          ..status = TaskStatusType.completed.id,
      );
    } else {
      task = task.rebuild(
        (b) => b
          ..done = false
          ..doneAt = null
          ..updatedAt = now
          ..status = lastDoneTaskStatus?.id,
      );
    }

    emit(state.copyWith(newTask: task));
  }

  void removeLink(String link) {
    Task task = state.newTask.rebuild((b) => b..links.remove(link));

    emit(state.copyWith(newTask: task));
  }

  void duplicate() {
    // TODO duplicate
  }

  void snooze(DateTime date) {
    // TODO snooze
  }

  void delete() {
    // TODO delete
  }

  void setDeadline(DateTime date) {
    Task task = state.newTask.rebuild((b) => b..dueDate = date);

    emit(state.copyWith(newTask: task));
  }
}
