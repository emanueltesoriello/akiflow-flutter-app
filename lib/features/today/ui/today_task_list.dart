import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/components/task/task_row.dart';
import 'package:mobile/features/edit_task/ui/actions/labels_modal.dart';
import 'package:mobile/features/plan_modal/ui/plan_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:reorderables/reorderables.dart';

class TodayTaskList extends StatelessWidget {
  final List<Task> tasks;
  final Widget header;
  final TaskListSorting sorting;
  final bool showTasks;

  const TodayTaskList({
    Key? key,
    required this.tasks,
    required this.sorting,
    required this.header,
    required this.showTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO IMPROVEMENT: Use ReorderableListView.builder when onReorderStart will
    //be available in flutter stable branch
    return ReorderableSliverList(
      onReorderStarted: (index) {
        int indexWithoutHeaderWidget = index - 1;

        context.read<TasksCubit>().select(tasks[indexWithoutHeaderWidget]);
      },
      buildDraggableFeedback: (context, constraints, child) {
        return Material(
          child: ConstrainedBox(constraints: constraints, child: child),
          elevation: 1,
          color: ColorsExt.grey6(context),
          borderRadius: BorderRadius.zero,
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
            return header;
          }

          index -= 1;

          if (showTasks == false) {
            return const SizedBox();
          }

          Task task = tasks[index];

          return TaskRow(
            key: ObjectKey(task),
            task: task,
            hideInboxLabel: false,
            selectMode: tasks.any((element) => element.selected ?? false),
            completedClick: () {
              context.read<TasksCubit>().markAsDone(task);
            },
            swipeActionPlanClick: () {
              _showPlan(context, task, TaskStatusType.planned);
            },
            swipeActionSelectLabelClick: () {
              var cubit = context.read<TasksCubit>();

              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => LabelsModal(
                  selectLabel: (Label label) {
                    cubit.assignLabel(label, task: task);
                  },
                ),
              );
            },
            swipeActionSnoozeClick: () {
              _showPlan(context, task, TaskStatusType.snoozed);
            },
          );
        },
        childCount: tasks.length + 1,
      ),
    );
  }

  void _showPlan(BuildContext context, Task task, TaskStatusType statusType) {
    TasksCubit cubit = context.read<TasksCubit>();

    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: PlanModal(
          statusType: statusType,
          onAddTimeClick: (DateTime? date, TaskStatusType statusType) {
            cubit.planFor(
              date,
              statusType: statusType,
              task: task,
            );
          },
          setForInbox: () {
            cubit.planFor(
              null,
              statusType: TaskStatusType.inbox,
              task: task,
            );
          },
          setForSomeday: () {
            cubit.planFor(
              null,
              statusType: TaskStatusType.someday,
              task: task,
            );
          },
        ),
      ),
    );
  }
}
