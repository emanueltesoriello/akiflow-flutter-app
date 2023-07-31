import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/models/mark_as_done_type.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/task_row.dart';
import 'package:mobile/src/base/ui/widgets/task/task_row_drag_mode.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/widgets/mark_done_modal.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/labels_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/plan_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

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
  final bool wasEmpty;
  final Function? afterAddingFirstTask;

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
    this.afterAddingFirstTask,
    this.wasEmpty = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
  }) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  double? opacityOfTaskRow;
  String idOfNewTask = '';

  @override
  void didUpdateWidget(covariant TaskList oldWidget) {
    idOfNewTask = '';
    try {
      if (widget.key.toString() == oldWidget.key.toString() && (widget.tasks.length > oldWidget.tasks.length)) {
        // Get the ID of the new just added task
        final List<String> oldIds = oldWidget.tasks.map((Task task) => task.id ?? '').toList();
        final List<String> newIds = widget.tasks.map((Task task) => task.id ?? '').toList();
        var differenceList = newIds.where((id) => !oldIds.contains(id)).toList();
        idOfNewTask = differenceList.last;

        setState(() {
          opacityOfTaskRow = 0;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            opacityOfTaskRow = 1;
          });
        });
      } else if ((widget.key.toString() == oldWidget.key.toString() && widget.wasEmpty)) {
        idOfNewTask = widget.tasks.first.id!;
        setState(() {
          opacityOfTaskRow = 0;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            opacityOfTaskRow = 1;
          });
        });
        if (widget.afterAddingFirstTask != null) {
          widget.afterAddingFirstTask!();
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        opacityOfTaskRow = 1;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

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
      },
      child: SlidableAutoCloseBehavior(
        child: ReorderableListView.builder(
          itemCount: tasks.length,
          scrollController: widget.scrollController,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          onReorder: (int oldIndex, int newIndex) {
            print('onReorder');
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
            print('onReorderStart');
            HapticFeedback.selectionClick();
            context.read<TasksCubit>().select(tasks[index]);
          },
          proxyDecorator: (Widget child, int index, Animation<double> animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double animValue = Curves.easeInOut.transform(animation.value);
                final double elevation = lerpDouble(0, 0.5, animValue)!;
                final double color = lerpDouble(0, 1, animValue)!;

                return Theme(
                  data: Theme.of(context).copyWith(useMaterial3: true),
                  child: Material(
                    elevation: elevation,
                    borderRadius: BorderRadius.zero,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: color == 0 ? ColorsExt.grey100(context) : null,
                      child: TaskRowDragMode(tasks[index]),
                    ),
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

            return GestureDetector(
              key: ObjectKey(task.id),
              onLongPress:
                  tasks.any((element) => element.selected ?? false) ? () => TaskExt.editTask(context, task) : null,
              onTap: tasks.any((element) => element.selected ?? false)
                  ? () => {HapticFeedback.selectionClick(), context.read<TasksCubit>().select(task)}
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                    color: task.id == idOfNewTask
                        ? (opacityOfTaskRow != null && opacityOfTaskRow == 0 ? ColorsExt.grey100(context) : null)
                        : null),
                child: AbsorbPointer(
                  absorbing: tasks.any((element) => element.selected ?? false),
                  child: BlocProvider(
                    key: ObjectKey(task.id),
                    create: (context) => editTaskCubit,
                    child: TaskRow(
                      task: task,
                      hideInboxLabel: widget.hideInboxLabel,
                      showLabel: widget.showLabel,
                      showPlanInfo: widget.showPlanInfo,
                      selectTask: () {
                        HapticFeedback.heavyImpact();
                        context.read<TasksCubit>().select(task);
                      },
                      selectMode: tasks.any((element) => element.selected ?? false),
                      completedClick: () async {
                        HapticFeedback.mediumImpact();
                        if (task.connectorId?.value != null && task.connectorId!.value! != 'gmail') {
                          IntegrationsCubit integrationsCubit = context.read<IntegrationsCubit>();
                          Account account = integrationsCubit.state.accounts.firstWhere((element) =>
                              element.connectorId == task.connectorId?.value &&
                              element.originAccountId == task.originAccountId?.value);

                          String? markAsDoneKey = account.details?['mark_as_done_action'];
                          MarkAsDoneType markAsDoneType = MarkAsDoneType.fromKey(markAsDoneKey);

                          if (markAsDoneType == MarkAsDoneType.askMeEveryTime) {
                            MarkAsDoneType? selectedType = await showCupertinoModalBottomSheet(
                              context: context,
                              builder: (context) => MarkDoneModal(
                                askBehavior: true,
                                initialType: MarkAsDoneType.doNothing,
                                account: account,
                              ),
                            );
                            switch (selectedType) {
                              case MarkAsDoneType.markAsDone:
                                editTaskCubit.markAsDone(forceUpdate: true, forceMarkAsDoneRemote: true);
                                break;
                              case MarkAsDoneType.changeList:
                                editTaskCubit.markAsDone(forceUpdate: true, forceMarkAsDoneRemote: true);
                                break;
                              case MarkAsDoneType.archive:
                                editTaskCubit.markAsDone(forceUpdate: true, forceArchiveRemote: true);
                                break;
                              case MarkAsDoneType.goTo:
                                editTaskCubit
                                    .markAsDone(forceUpdate: true)
                                    .then((value) => tasksCubit.goToUrl(task.doc['url']));
                                break;
                              default:
                                editTaskCubit.markAsDone(forceUpdate: true);
                            }
                          } else {
                            editTaskCubit.markAsDone(forceUpdate: true);
                          }
                        } else {
                          editTaskCubit.markAsDone(forceUpdate: true);
                        }
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
