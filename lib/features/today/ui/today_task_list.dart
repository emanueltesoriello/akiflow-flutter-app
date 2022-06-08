import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/components/task/task_row.dart';
import 'package:mobile/components/task/task_row_drag_mode.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/labels_modal.dart';
import 'package:mobile/features/edit_task/ui/actions/plan_modal.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class TodayTaskList extends StatefulWidget {
  final List<Task> tasks;
  final Widget? header;
  final Widget? footer;
  final TaskListSorting? sorting;
  final bool showTasks;
  final bool showLabel;
  final bool showPlanInfo;
  final bool enableReorder;

  const TodayTaskList({
    Key? key,
    required this.tasks,
    required this.header,
    required this.footer,
    required this.showTasks,
    required this.showLabel,
    required this.showPlanInfo,
    this.enableReorder = true,
    this.sorting,
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

  Task? selected;

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = List.from(widget.tasks);

    return ReorderableListView.builder(
      scrollController: scrollController,
      key: widget.key,
      itemCount: tasks.length,
      shrinkWrap: true,
      buildDefaultDragHandles: widget.enableReorder,
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex--;
        }

        context.read<TasksCubit>().reorder(
              oldIndex,
              newIndex,
              newTasksListOrdered: tasks,
              sorting: widget.sorting,
              homeViewType: context.read<MainCubit>().state.homeViewType,
            );
      },
      onReorderStart: (index) {
        int indexWithoutHeaderWidget = index;

        selected = tasks[indexWithoutHeaderWidget];

        context.read<TasksCubit>().select(selected!);
      },
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(0, 1, animValue)!;
            return Theme(
              data: Theme.of(context).copyWith(useMaterial3: false),
              child: Material(
                elevation: elevation,
                color: ColorsExt.grey6(context),
                borderRadius: BorderRadius.zero,
                child: TaskRowDragMode(selected!),
              ),
            );
          },
          child: child,
        );
      },
      header: Builder(builder: (context) {
        if (widget.header != null) {
          return GestureDetector(key: const ObjectKey("header"), onLongPress: () {}, child: widget.header!);
        }

        return const SizedBox();
      }),
      footer: Builder(builder: (context) {
        if (widget.footer != null) {
          return GestureDetector(
            key: const ObjectKey("footer"),
            onLongPress: () {},
            child: Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: widget.footer!),
          );
        }

        return const SizedBox();
      }),
      itemBuilder: (context, index) {
        if (widget.showTasks == false) {
          return SizedBox(key: UniqueKey());
        }

        Task task = tasks[index];
        TasksCubit tasksCubit = context.read<TasksCubit>();
        SyncCubit syncCubit = context.read<SyncCubit>();

        EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);

        return BlocProvider(
          key: ObjectKey(task),
          create: (context) => editTaskCubit,
          child: TaskRow(
            key: ObjectKey(task),
            task: task,
            hideInboxLabel: false,
            showLabel: widget.showLabel,
            showPlanInfo: widget.showPlanInfo,
            additionalTopPadding: index == 0 ? 4 : 0,
            enableLongPressToSelect: widget.enableReorder == false,
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
                  showNoLabel: task.listId != null,
                ),
              );
            },
            swipeActionSnoozeClick: () {
              _showPlan(context, task, TaskStatusType.snoozed, editTaskCubit);
            },
          ),
        );
      },
    );
  }

  void _showPlan(BuildContext context, Task task, TaskStatusType statusType, EditTaskCubit editTaskCubit) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: editTaskCubit,
        child: PlanModal(
          initialDate: task.date != null ? DateTime.parse(task.date!) : DateTime.now(),
          initialDatetime: task.datetime != null ? DateTime.parse(task.datetime!).toLocal() : null,
          initialHeaderStatusType: statusType,
          taskStatusType: task.statusType ?? TaskStatusType.planned,
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
