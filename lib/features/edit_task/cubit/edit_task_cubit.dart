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
  bool isCreateMode;

  EditTaskCubit(
    this._tasksCubit, {
    Task? task,
    TaskStatusType? taskStatusType,
    DateTime? date,
    required this.isCreateMode,
  }) : super(
          EditTaskCubitState(
            newTask: task ??
                const Task().copyWith(
                  id: const Uuid().v4(),
                  status: taskStatusType != null ? taskStatusType.id : task?.status,
                  date: Nullable(
                      (taskStatusType == TaskStatusType.planned && date != null) ? date.toIso8601String() : null),
                ),
          ),
        );

  void setRead() {
    DateTime now = DateTime.now().toUtc();

    Task updated = state.newTask.copyWith(
      readAt: now.toIso8601String(),
    );

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

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
      readAt: now.toIso8601String(),
    );

    emit(state.copyWith(newTask: updated));

    await _tasksRepository.add([updated]);

    _tasksCubit.updateUiOfTask(updated);

    _tasksCubit.syncAll();
  }

  Future<void> planFor(
    DateTime? date, {
    DateTime? dateTime,
    required TaskStatusType statusType,
  }) async {
    emit(state.copyWith(selectedDate: date));

    Task task = state.newTask;

    Task updated = task.copyWith(
      date: Nullable(date?.toIso8601String()),
      datetime: dateTime?.toIso8601String(),
      status: statusType.id,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void setDuration(double value) {
    emit(state.copyWith(selectedDuration: value));

    Task task = state.newTask;

    double seconds = value * 3600;

    Task updated = task.copyWith(
      duration: Nullable(seconds.toInt()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void toggleDuration() {
    emit(state.copyWith(setDuration: !state.setDuration));

    if (state.setDuration == false) {
      Task updated = state.newTask.copyWith(
        duration: Nullable(null),
        updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
      );

      emit(state.copyWith(newTask: updated));

      if (isCreateMode == false) {
        _updateUiRepositoryAndSync(updated);
      }
    }
  }

  void toggleLabels() {
    emit(state.copyWith(showLabelsList: !state.showLabelsList));
  }

  void setLabel(Label label) {
    Task updated = state.newTask.copyWith(
      listId: label.id,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(
      selectedLabel: label,
      showLabelsList: false,
      newTask: updated,
    ));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void markAsDone() {
    Task task = state.newTask;

    if (isCreateMode == false) {
      _tasksCubit.addToUndoQueue([task], task.isCompletedComputed ? UndoType.markUndone : UndoType.markDone);
    }

    Task updated = task.markAsDone(
      lastDoneTaskStatus: lastDoneTaskStatus,
      onDone: (status) {
        lastDoneTaskStatus = status;
      },
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void removeLink(String link) {
    Task updated = state.newTask.copyWith(
      links: (state.newTask.links ?? []).where((l) => l != link).toList(),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  Future<void> delete() async {
    Task task = state.newTask;

    if (isCreateMode == false) {
      _tasksCubit.addToUndoQueue([task], UndoType.delete);
    }

    Task updated = task.copyWith(
      status: TaskStatusType.deleted.id,
      deletedAt: (DateTime.now().toUtc().toIso8601String()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void setDeadline(DateTime? date) {
    Task task = state.newTask;

    Task updated = task.copyWith(
      dueDate: Nullable(date?.toIso8601String()),
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void toggleDailyGoal() {
    Task task = state.newTask;

    int currentDailyGoal = task.dailyGoal ?? 0;

    Task updated = state.newTask.copyWith(
      dailyGoal: currentDailyGoal == 0 ? 1 : 0,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  void changePriority() {
    Task task = state.newTask;

    int currentPriority = task.priority ?? 0;

    if (currentPriority + 1 > 3) {
      currentPriority = -1;
    } else {
      if (currentPriority < 1) {
        currentPriority = 1;
      } else {
        currentPriority++;
      }
    }

    Task updated = task.copyWith(
      priority: currentPriority,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
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

    if (isCreateMode == false) {
      _updateUiRepositoryAndSync(updated);
    }
  }

  Future<void> duplicate() async {
    DateTime? now = DateTime.now().toUtc();

    Task task = state.newTask;

    Task newTaskDuplicated = task.copyWith(
      id: const Uuid().v4(),
      updatedAt: Nullable(now.toIso8601String()),
      createdAt: (now.toIso8601String()),
      selected: false,
    );

    _tasksCubit.updateUiOfTask(newTaskDuplicated);

    await _tasksRepository.add([newTaskDuplicated]);

    _tasksCubit.syncAll();
  }

  Timer? _timer;

  void onTitleChanged(String value) {
    if (_timer != null) {
      _timer?.cancel();
    }

    Task updated = state.newTask.copyWith(
      title: value,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    _timer = Timer(const Duration(seconds: 1), () {
      _timer = null;

      if (isCreateMode == false) {
        _updateUiRepositoryAndSync(updated);
      }
    });
  }

  void onDescriptionChanged(String value) {
    if (_timer != null) {
      _timer?.cancel();
    }

    Task updated = state.newTask.copyWith(
      description: value,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    emit(state.copyWith(newTask: updated));

    _timer = Timer(const Duration(seconds: 1), () {
      _timer = null;

      if (isCreateMode == false) {
        _updateUiRepositoryAndSync(updated);
      }
    });
  }

  _updateUiRepositoryAndSync(Task task) async {
    _tasksCubit.updateUiOfTask(task);

    await _tasksRepository.updateById(task.id!, data: task);

    _tasksCubit.syncAll();
  }
}
