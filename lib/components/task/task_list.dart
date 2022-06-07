import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/components/task/task_row.dart';
import 'package:mobile/components/task/task_row_drag_mode.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/labels_modal.dart';
import 'package:mobile/features/edit_task/ui/actions/plan_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:reorderables/reorderables.dart';

enum TaskListSorting { ascending, descending }

class TaskList extends StatefulWidget {
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
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  StreamSubscription? streamSubscription;
  ScrollController? scrollController;
  Task? selected;

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
    List<Task> tasks =
        List.from(widget.tasks.where((element) => element.deletedAt == null && !element.isCompletedComputed));

    tasks = TaskExt.sort(tasks, sorting: widget.sorting);

    return RefreshIndicator(
      backgroundColor: ColorsExt.background(context),
      onRefresh: () async {
        return context.read<SyncCubit>().sync();
      },
      child: SlidableAutoCloseBehavior(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          slivers: [
            // TODO IMPROVEMENT: Use ReorderableListView.builder when onReorderStart will
            //be available in flutter stable branch
            ReorderableSliverList(
              onReorderStarted: (index) {
                int indexWithoutHeaderWidget = index - 1;

                selected = tasks[indexWithoutHeaderWidget];

                context.read<TasksCubit>().select(selected!);
              },
              buildDraggableFeedback: (context, constraints, child) {
                return Material(
                  elevation: 1,
                  color: ColorsExt.grey6(context),
                  borderRadius: BorderRadius.zero,
                  child: ConstrainedBox(
                    constraints: constraints,
                    child: TaskRowDragMode(selected!),
                  ),
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
                  if (index == 0) {
                    if (widget.notice == null) {
                      return const SizedBox(key: ObjectKey(0), height: 0);
                    }

                    return Container(
                      key: ObjectKey(widget.notice),
                      child: widget.notice!,
                    );
                  }

                  index -= 1;

                  Task task = tasks[index];
                  TasksCubit tasksCubit = context.read<TasksCubit>();
                  SyncCubit syncCubit = context.read<SyncCubit>();

                  EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);

                  return BlocProvider(
                    create: (context) => editTaskCubit,
                    child: TaskRow(
                      key: ObjectKey(task),
                      task: task,
                      hideInboxLabel: widget.hideInboxLabel,
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
                childCount: tasks.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlan(BuildContext context, Task task, TaskStatusType initialHeaderStatusType, EditTaskCubit editTaskCubit) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: editTaskCubit,
        child: PlanModal(
          initialDate: task.date != null ? DateTime.parse(task.date!) : DateTime.now(),
          initialDatetime: task.datetime != null ? DateTime.parse(task.datetime!).toLocal() : null,
          taskStatusType: task.statusType ?? TaskStatusType.planned,
          initialHeaderStatusType: initialHeaderStatusType,
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
