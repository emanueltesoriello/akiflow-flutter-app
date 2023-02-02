import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/task_row.dart';
import 'package:mobile/src/base/ui/widgets/task/task_row_drag_mode.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/labels_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/plan_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:mobile/core/preferences.dart';

enum TaskListSorting {
  sortingAscending,
  sortingDescending,
  dateAscending,
  sortingLabelAscending,
  doneAtDescending,
  none
}

class TaskList extends StatefulWidget {
  final List<Task> tasks;

  final Widget? header;
  final Widget? footer;
  final bool hideInboxLabel;
  final TaskListSorting sorting;
  final bool showLabel;
  final bool showPlanInfo;
  final bool shrinkWrap;
  final bool visible;
  final ScrollController? scrollController;
  final ScrollPhysics physics;
  final bool addBottomPadding;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.sorting,
    this.header,
    this.footer,
    this.hideInboxLabel = false,
    required this.showLabel,
    required this.showPlanInfo,
    this.shrinkWrap = false,
    this.visible = true,
    this.addBottomPadding = false,
    this.scrollController,
    this.physics = const AlwaysScrollableScrollPhysics(),
  }) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    List<Task> tasks = List.from(widget.tasks);

    tasks = TaskExt.sort(tasks, sorting: widget.sorting);

    if (!widget.visible) {
      tasks = [];
    }

    return RefreshIndicator(
      backgroundColor: ColorsExt.background(context),
      onRefresh: () async {
        context.read<SyncCubit>().sync();
        NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
      },
      child: SlidableAutoCloseBehavior(
        child: ReorderableListView.builder(
          itemCount: tasks.length,
          scrollController: widget.scrollController,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
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
            HapticFeedback.selectionClick();
            context.read<TasksCubit>().select(tasks[index]);
          },
          proxyDecorator: (Widget child, int index, Animation<double> animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double animValue = Curves.easeInOut.transform(animation.value);
                final double elevation = lerpDouble(0, 1, animValue)!;
                return Theme(
                  data: Theme.of(context).copyWith(useMaterial3: true),
                  child: Material(
                    elevation: elevation,
                    color: ColorsExt.grey6(context),
                    borderRadius: BorderRadius.zero,
                    child: TaskRowDragMode(tasks[index]),
                  ),
                );
              },
              child: child,
            );
          },
          header: Visibility(
            visible: widget.header != null,
            replacement: const SizedBox(key: ObjectKey(0), height: 0),
            child: SizedBox(
              key: ObjectKey(widget.header),
              child: widget.header,
            ),
          ),
          footer: Visibility(
            visible: widget.footer != null,
            replacement: const SizedBox(key: ObjectKey(0), height: 0),
            child: SizedBox(
              key: ObjectKey(widget.footer),
              child: widget.footer,
            ),
          ),
          itemBuilder: (context, index) {
            Task task = tasks[index];

            TasksCubit tasksCubit = context.read<TasksCubit>();
            SyncCubit syncCubit = context.read<SyncCubit>();

            EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);

            return Padding(
              key: ObjectKey(task),
              padding: widget.addBottomPadding
                  ? EdgeInsets.only(bottom: index == tasks.length - 1 ? 100 : 0)
                  : EdgeInsets.zero,
              child: BlocProvider(
                key: ObjectKey(task),
                create: (context) => editTaskCubit,
                child: TaskRow(
                  key: ObjectKey(task),
                  task: task,
                  hideInboxLabel: widget.hideInboxLabel,
                  showLabel: widget.showLabel,
                  showPlanInfo: widget.showPlanInfo,
                  selectTask: () {
                    HapticFeedback.selectionClick();
                    context.read<TasksCubit>().select(task);
                  },
                  selectMode: tasks.any((element) => element.selected ?? false),
                  completedClick: () {
                    HapticFeedback.mediumImpact();
                    editTaskCubit.markAsDone(forceUpdate: true);
                  },
                  swipeActionPlanClick: () {
                    HapticFeedback.mediumImpact();
                    _showPlan(context, task, TaskStatusType.planned, editTaskCubit);
                  },
                  swipeActionSelectLabelClick: () {
                    HapticFeedback.mediumImpact();
                    showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) => LabelsModal(
                        selectLabel: (Label label) {
                          Navigator.pop(context);
                          editTaskCubit.setLabel(label, forceUpdate: true);
                        },
                        showNoLabel: true,
                      ),
                    );
                  },
                  swipeActionSnoozeClick: () {
                    HapticFeedback.mediumImpact();
                    _showPlan(context, task, TaskStatusType.snoozed, editTaskCubit);
                  },
                ),
              ),
            );
          },
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
