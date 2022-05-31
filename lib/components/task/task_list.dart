import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/components/task/task_row.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/labels_modal.dart';
import 'package:mobile/features/plan_modal/ui/plan_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:reorderables/reorderables.dart';

enum TaskListSorting { ascending, descending }

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  final Widget? notice;
  final bool hideInboxLabel;
  final TaskListSorting sorting;
  final bool showLabel;
  final bool showPlanInfo;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.sorting,
    this.notice,
    this.hideInboxLabel = false,
    required this.showLabel,
    required this.showPlanInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> tasks =
        List.from(this.tasks.where((element) => element.deletedAt == null && !element.isCompletedComputed));

    tasks = TaskExt.sort(tasks, sorting: sorting);

    return RefreshIndicator(
      onRefresh: () async {
        return context.read<SyncCubit>().sync();
      },
      child: SlidableAutoCloseBehavior(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: PrimaryScrollController.of(context) ?? ScrollController(),
          slivers: [
            // TODO IMPROVEMENT: Use ReorderableListView.builder when onReorderStart will
            //be available in flutter stable branch
            ReorderableSliverList(
              onReorderStarted: (index) {
                int indexWithoutHeaderWidget = index - 1;

                context.read<TasksCubit>().select(tasks[indexWithoutHeaderWidget]);
              },
              buildDraggableFeedback: (context, constraints, child) {
                return Material(
                  elevation: 1,
                  color: ColorsExt.grey6(context),
                  borderRadius: BorderRadius.zero,
                  child: ConstrainedBox(constraints: constraints, child: child),
                );
              },
              onReorder: (int oldIndex, int newIndex) {
                context.read<TasksCubit>().reorder(
                      oldIndex - 1,
                      newIndex - 1,
                      newTasksListOrdered: tasks,
                      sorting: sorting,
                    );
              },
              delegate: ReorderableSliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == 0) {
                    if (notice == null) {
                      return const SizedBox(key: ObjectKey(0), height: 0);
                    }

                    return Container(
                      key: ObjectKey(notice),
                      child: notice!,
                    );
                  }

                  index -= 1;

                  Task task = tasks[index];
                  TasksCubit tasksCubit = context.read<TasksCubit>();
                  SyncCubit syncCubit = context.read<SyncCubit>();

                  EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit, task: task);

                  return BlocProvider(
                    create: (context) => editTaskCubit,
                    child: TaskRow(
                      key: ObjectKey(task),
                      task: task,
                      hideInboxLabel: hideInboxLabel,
                      showLabel: showLabel,
                      showPlanInfo: showPlanInfo,
                      selectTask: () {
                        context.read<TasksCubit>().select(task);
                      },
                      selectMode: tasks.any((element) => element.selected ?? false),
                      completedClick: () {
                        editTaskCubit.markAsDone(forceUpdate: true);
                      },
                      swipeActionPlanClick: () {
                        _showPlan(context, task, TaskStatusType.planned, editTaskCubit);
                      },
                      swipeActionSelectLabelClick: () {
                        showCupertinoModalBottomSheet(
                          context: context,
                          builder: (context) => LabelsModal(
                            selectLabel: (Label label) {
                              editTaskCubit.setLabel(label, forceUpdate: true);
                            },
                          ),
                        );
                      },
                      swipeActionSnoozeClick: () {
                        _showPlan(context, task, TaskStatusType.snoozed, editTaskCubit);
                      },
                    ),
                  );
                },
                childCount: tasks.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlan(BuildContext context, Task task, TaskStatusType statusType, EditTaskCubit editTaskCubit) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: editTaskCubit,
        child: PlanModal(
          statusType: statusType,
          onSelectDate: ({required DateTime? date, required DateTime? datetime, required TaskStatusType statusType}) {
            editTaskCubit.planFor(
              date,
              dateTime: datetime,
              statusType: statusType,
              forceUpdate: true,
            );
          },
          setForInbox: () {
            editTaskCubit.planFor(
              null,
              dateTime: null,
              statusType: TaskStatusType.inbox,
              forceUpdate: true,
            );
          },
          setForSomeday: () {
            editTaskCubit.planFor(
              null,
              dateTime: null,
              statusType: TaskStatusType.someday,
              forceUpdate: true,
            );
          },
        ),
      ),
    );
  }
}
