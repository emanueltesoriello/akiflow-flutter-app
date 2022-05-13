import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';
import 'package:uuid/uuid.dart';

part 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  final TasksCubit _tasksCubit;

  TaskStatusType? lastDoneTaskStatus;

  EditTaskCubit(this._tasksCubit, {Task? task, TaskStatusType? taskStatusType, DateTime? date})
      : super(
          EditTaskCubitState(
            newTask: task ??
                const Task().copyWith(
                  id: const Uuid().v4(),
                  status: taskStatusType != null ? taskStatusType.id : task?.status,
                  date: Nullable(
                      (taskStatusType == TaskStatusType.planned && date != null) ? date.toIso8601String() : null),
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
    DateTime now = DateTime.now().toUtc();

    Task updated = state.newTask.copyWith(
      title: title,
      description: description,
      updatedAt: Nullable(now.toIso8601String()),
      createdAt: (now.toIso8601String()),
      listId: state.selectedLabel?.id,
    );

    emit(state.copyWith(newTask: updated));

    await _tasksRepository.add([updated]);

    _tasksCubit.updateUiOfTask(updated);

    _tasksCubit.syncAll();
  }

  Future<void> planFor(
    DateTime? date, {
    DateTime? dateTime,
    bool? update = true,
    required TaskStatusType statusType,
  }) async {
    Task updated = state.newTask.copyWith(
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    updated = updated.planFor(
      date: date,
      dateTime: dateTime,
      status: statusType.id,
    );

    emit(state.copyWith(newTask: updated));

    if (update!) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  Future<void> setForInbox() async {
    Task updated = state.newTask.copyWith(
      date: Nullable(null),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      status: TaskStatusType.inbox.id,
    );

    emit(state.copyWith(newTask: updated));

    _updateUiRepositoryAndSync(updated);
  }

  Future<void> setSomeday() async {
    Task updated = state.newTask.copyWith(
      date: Nullable(null),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      status: TaskStatusType.someday.id,
    );

    emit(state.copyWith(newTask: updated));

    _updateUiRepositoryAndSync(updated);
  }

  Future<void> selectDate(
    DateTime selectedDate, {
    bool update = true,
  }) async {
    emit(state.copyWith(selectedDate: selectedDate));

    Task updated = state.newTask.copyWith(
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    updated = updated.planFor(date: selectedDate, status: TaskStatusType.planned.id);

    emit(state.copyWith(newTask: updated));

    if (update) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void setDuration(
    double value, {
    bool update = true,
  }) {
    emit(state.copyWith(selectedDuration: value));

    double seconds = value * 3600;

    Task updated = state.newTask.copyWith(
      duration: Nullable(seconds.toInt()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (update) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void toggleDuration({bool update = true}) {
    emit(state.copyWith(setDuration: !state.setDuration));

    if (state.setDuration == false) {
      Task updated = state.newTask.copyWith(
        duration: Nullable(null),
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      emit(state.copyWith(newTask: updated));

      if (update) {
        _updateUiRepositoryAndSync(updated);
      }
    }
  }

  void toggleLabels() {
    emit(state.copyWith(showLabelsList: !state.showLabelsList));
  }

  void setLabel(Label label, {bool update = true}) {
    Task updated = state.newTask.copyWith(
      listId: label.id,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(
      selectedLabel: label,
      showLabelsList: false,
      newTask: updated,
    ));

    if (update) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void markAsDone(Task task) {
    Task updated = task.copyWith(
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    updated = task.markAsDone(
      lastDoneTaskStatus: lastDoneTaskStatus,
      onDone: (status) {
        lastDoneTaskStatus = status;
      },
    );

    emit(state.copyWith(newTask: updated));

    _updateUiRepositoryAndSync(updated);
  }

  void removeLink(String link) {
    Task task = state.newTask.copyWith(
      links: (state.newTask.links ?? []).where((l) => l != link).toList(),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: task));

    _updateUiRepositoryAndSync(task);
  }

  void snooze(DateTime date) {
    Task updated = state.newTask.copyWith(
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    updated = updated.planFor(date: date, status: TaskStatusType.snoozed.id);

    emit(state.copyWith(newTask: updated));

    _updateUiRepositoryAndSync(updated);
  }

  Future<void> delete() async {
    Task updated = state.newTask.copyWith(
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    updated = updated.delete();

    emit(state.copyWith(newTask: updated));

    _updateUiRepositoryAndSync(updated);
  }

  void setDeadline(DateTime? date, {bool update = true}) {
    Task updated = state.newTask.copyWith(
      dueDate: Nullable(date?.toIso8601String()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (update) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void toggleDailyGoal() {
    int currentDailyGoal = state.newTask.dailyGoal ?? 0;

    Task task = state.newTask.copyWith(
      dailyGoal: currentDailyGoal == 0 ? 1 : 0,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: task));

    _updateUiRepositoryAndSync(task);
  }

  void changePriority() {
    int currentPriority = state.newTask.priority ?? 0;

    if (currentPriority + 1 > 3) {
      currentPriority = -1;
    } else {
      if (currentPriority < 1) {
        currentPriority = 1;
      } else {
        currentPriority++;
      }
    }

    Task updated = state.newTask.copyWith(
      priority: currentPriority,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    _updateUiRepositoryAndSync(updated);
  }

  _updateUiRepositoryAndSync(Task task) async {
    _tasksCubit.updateUiOfTask(task);

    await _tasksRepository.updateById(task.id!, data: task);

    _tasksCubit.syncAll();
  }

  void setRecurrence(RecurrenceRule? rule) {
    List<String>? recurrence = [];

    if (rule != null) {
      String recurrenceString = rule.toString();
      recurrence = recurrenceString.split(';');
    }

    Task updated = state.newTask.copyWith(
      recurrence: Nullable(recurrence),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    _updateUiRepositoryAndSync(updated);
  }

  Timer? _timer;

  void onTitleChanged(String value) {
    if (_timer != null) {
      _timer?.cancel();
    }

    _timer = Timer(const Duration(seconds: 1), () {
      _timer = null;

      Task updated = state.newTask.copyWith(
        title: value,
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      emit(state.copyWith(newTask: updated));

      _updateUiRepositoryAndSync(updated);
    });
  }

  void onDescriptionChanged(String value) {
    if (_timer != null) {
      _timer?.cancel();
    }

    _timer = Timer(const Duration(seconds: 1), () {
      _timer = null;

      Task updated = state.newTask.copyWith(
        description: value,
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      emit(state.copyWith(newTask: updated));

      _updateUiRepositoryAndSync(updated);
    });
  }
}
