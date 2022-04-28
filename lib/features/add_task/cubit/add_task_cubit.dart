import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';
import 'package:uuid/uuid.dart';

part 'add_task_state.dart';

class AddTaskCubit extends Cubit<AddTaskCubitState> {
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final SyncControllerService _syncControllerService =
      locator<SyncControllerService>();

  final TasksCubit _tasksCubit;

  AddTaskCubit(this._tasksCubit)
      : super(
          AddTaskCubitState(
            newTask: Task().rebuild(
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
        ..createdAt = now,
    );

    emit(state.copyWith(newTask: updated));

    List<Task> all = _tasksCubit.state.tasks.toList();

    all.add(updated);

    _tasksCubit.emit(_tasksCubit.state.copyWith(tasks: all));

    await _tasksRepository.add([updated]);

    await _syncControllerService.syncTasks();

    _tasksCubit.refreshTasks();
  }

  void selectPlanType(AddTaskPlanType type) {
    emit(state.copyWith(planType: type));
  }

  void planFor(DateTime date, {DateTime? dateTime}) {
    Task updated = state.newTask.rebuild(
      (b) => b
        ..date = date.toUtc()
        ..datetime = dateTime?.toUtc()
        ..status = state.planType == AddTaskPlanType.plan
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
}
