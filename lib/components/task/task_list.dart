import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/components/task/sync_status_item.dart';
import 'package:mobile/components/task/task_row.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';
import 'package:reorderables/reorderables.dart';

enum TaskListSorting { ascending, descending }

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  final Widget? notice;
  final bool hideInboxLabel;
  final TaskListSorting sorting;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.sorting,
    this.notice,
    this.hideInboxLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = List.from(this.tasks);

    tasks = TaskExt.sort(tasks, sorting: sorting);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await context.read<TasksCubit>().syncAllAndRefresh();
          },
          child: SlidableAutoCloseBehavior(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller:
                  PrimaryScrollController.of(context) ?? ScrollController(),
              slivers: [
                // TODO IMPROVEMENT: Use ReorderableListView.builder when onReorderStart will
                //be available in flutter stable branch
                ReorderableSliverList(
                  onReorderStarted: (index) {
                    int indexWithoutHeaderWidget = index - 2;

                    context
                        .read<TasksCubit>()
                        .select(tasks[indexWithoutHeaderWidget]);
                  },
                  buildDraggableFeedback: (context, constraints, child) {
                    return Material(
                      child: ConstrainedBox(
                          constraints: constraints, child: child),
                      elevation: 1,
                      color: ColorsExt.grey6(context),
                      borderRadius: BorderRadius.zero,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    context.read<TasksCubit>().reorder(
                          oldIndex - 2,
                          newIndex - 2,
                          newTasksListOrdered: tasks,
                          sorting: sorting,
                        );
                  },
                  delegate: ReorderableSliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index == 0) {
                        return const SyncStatusItem();
                      }

                      if (index == 1) {
                        if (notice == null) {
                          return const SizedBox(key: ObjectKey(0), height: 0);
                        }

                        return Container(
                          key: ObjectKey(notice),
                          child: notice!,
                        );
                      }

                      index -= 2;

                      Task task = tasks[index];

                      return TaskRow(
                        key: ObjectKey(task),
                        task: task,
                        hideInboxLabel: hideInboxLabel,
                        selectMode:
                            tasks.any((element) => element.selected ?? false),
                        completedClick: () {
                          context.read<TasksCubit>().markAsDone(task);
                        },
                        planClick: () {
                          // TODO open calendar and plan
                        },
                        selectLabelClick: () {
                          // TODO open labels and save
                        },
                        snoozeClick: () {
                          // TODO open calendar and snooze
                        },
                      );
                    },
                    childCount: tasks.length + 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
