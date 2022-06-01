import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/task/task_list.dart';
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

class TodayTaskList extends StatefulWidget {
  final List<Task> tasks;
  final Widget? header;
  final Widget? footer;
  final TaskListSorting sorting;
  final bool showTasks;
  final bool showLabel;
  final bool showPlanInfo;

  const TodayTaskList({
    Key? key,
    required this.tasks,
    required this.sorting,
    required this.header,
    required this.footer,
    required this.showTasks,
    required this.showLabel,
    required this.showPlanInfo,
  }) : super(key: key);

  @override
  State<TodayTaskList> createState() => _TodayTaskListState();
}

class _TodayTaskListState extends State<TodayTaskList> {
  StreamSubscription? streamSubscription;
  ScrollController? scrollController;

  @override
  void initState() {
    scrollController = ScrollController();

    TasksCubit tasksCubit = context.read<TasksCubit>();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    streamSubscription = tasksCubit.scrollTopStream.listen((allSelected) {
      scrollController?.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = List.from(widget.tasks);

    tasks = TaskExt.sort(tasks, sorting: widget.sorting);

    // TODO IMPROVEMENT: Use ReorderableListView.builder when onReorderStart will
    //be available in flutter stable branch
    return ReorderableSliverList(
      controller: scrollController,
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
              sorting: widget.sorting,
            );
      },
      delegate: ReorderableSliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == tasks.length + 1) {
            if (widget.footer != null) {
              return Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: widget.footer!);
            }

            return const SizedBox();
          }

          if (index == 0) {
            if (widget.header != null) {
              return widget.header!;
            }

            return const SizedBox();
          }

          index -= 1;

          if (widget.showTasks == false) {
            return const SizedBox();
          }

          Task task = tasks[index];
          TasksCubit tasksCubit = context.read<TasksCubit>();
          SyncCubit syncCubit = context.read<SyncCubit>();

          EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTaskAndLabel(task);

          return BlocProvider(
            create: (context) => editTaskCubit,
            child: TaskRow(
              key: ObjectKey(task),
              task: task,
              hideInboxLabel: false,
              showLabel: widget.showLabel,
              showPlanInfo: widget.showPlanInfo,
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
        childCount: tasks.length + 2,
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
