import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/task/task_row.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/labels_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/plan_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class GroupedTasksModal extends StatelessWidget {
  final List<Task> tasks;
  const GroupedTasksModal({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    TasksCubit tasksCubit = context.watch<TasksCubit>();
    List<Task> calendarTasks = List.from(tasksCubit.state.calendarTasks);

    List<String> idList = tasks.map((e) => e.id!).toList();

    List<Task> tasksInGroup = calendarTasks.where((task) => idList.contains(task.id)).toList();

    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: Dimension.padding),
            const ScrollChip(),
            const SizedBox(height: Dimension.padding),
            Padding(
              padding: const EdgeInsets.all(Dimension.padding),
              child: Row(
                children: [
                  Text(
                    ' ${tasks.length} tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ColorsExt.grey2(context),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: tasksInGroup.length,
              itemBuilder: (context, index) {
                Task task = tasksInGroup[index];

                TasksCubit tasksCubit = context.read<TasksCubit>();
                SyncCubit syncCubit = context.read<SyncCubit>();

                EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);

                return BlocProvider(
                  key: ObjectKey(task),
                  create: (context) => editTaskCubit,
                  child: TaskRow(
                    key: ObjectKey(task),
                    task: task,
                    openedFromCalendarGroupedTasks: true,
                    showLabel: true,
                    showPlanInfo: false,
                    selectTask: () {},
                    selectMode: false,
                    completedClick: () {
                      HapticFeedback.mediumImpact();
                      editTaskCubit.markAsDone(forceUpdate: true);
                    },
                    swipeActionPlanClick: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      _showPlan(context, task, TaskStatusType.planned, editTaskCubit);
                    },
                    swipeActionSelectLabelClick: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
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
                );
              },
            ),
            const SizedBox(height: 48),
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
