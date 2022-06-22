import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/base/tagbox.dart';
import 'package:mobile/components/task/plan_for_action.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/plan_modal.dart';
import 'package:mobile/features/edit_task/ui/actions/recurrence_modal.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/task/task.dart';
import 'package:rrule/rrule.dart';

class EditTaskTopActions extends StatefulWidget {
  const EditTaskTopActions({Key? key}) : super(key: key);

  @override
  State<EditTaskTopActions> createState() => _EditTaskTopActionsState();
}

class _EditTaskTopActionsState extends State<EditTaskTopActions> {
  @override
  Widget build(BuildContext context) {
    Task updatedTask = context.watch<EditTaskCubit>().state.updatedTask;

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          PlanForAction(
            task: updatedTask,
            onTap: () {
              EditTaskCubit cubit = context.read<EditTaskCubit>();

              cubit.planTap();

              TaskStatusType initialHeaderStatusType;

              if (updatedTask.statusType == TaskStatusType.snoozed ||
                  updatedTask.statusType == TaskStatusType.someday) {
                initialHeaderStatusType = TaskStatusType.snoozed;
              } else {
                initialHeaderStatusType = TaskStatusType.planned;
              }

              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: PlanModal(
                    initialDate: updatedTask.date != null ? DateTime.parse(updatedTask.date!) : DateTime.now(),
                    initialDatetime:
                        updatedTask.datetime != null ? DateTime.parse(updatedTask.datetime!).toLocal() : null,
                    taskStatusType: updatedTask.statusType ?? TaskStatusType.planned,
                    initialHeaderStatusType: initialHeaderStatusType,
                    onSelectDate: (
                        {required DateTime? date, required DateTime? datetime, required TaskStatusType statusType}) {
                      cubit.planFor(date, dateTime: datetime, statusType: statusType);
                    },
                    setForInbox: () {
                      cubit.planFor(null, statusType: TaskStatusType.inbox);
                    },
                    setForSomeday: () {
                      cubit.planFor(null, statusType: TaskStatusType.someday);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Builder(builder: ((context) {
            Task task = updatedTask;

            String? text;

            if (task.duration != null && task.duration != 0) {
              int seconds = task.duration!;

              double hours = seconds / 3600;
              double minutes = (hours - hours.floor()) * 60;

              if (minutes.floor() == 0) {
                text = '${hours.floor()}h';
              } else if (hours.floor() == 0) {
                text = '${minutes.floor()}m';
              } else {
                text = '${hours.floor()}h ${minutes.floor()}m';
              }
            }

            return TagBox(
              icon: "assets/images/icons/_common/hourglass.svg",
              backgroundColor:
                  task.duration != null && task.duration != 0 ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
              active: task.duration != null && task.duration != 0,
              isSquare: task.duration != null && task.duration != 0 ? false : true,
              text: text,
              isBig: true,
              onPressed: () {
                context.read<EditTaskCubit>().toggleDuration();
              },
            );
          })),
          const SizedBox(width: 8),
          Builder(
            builder: (context) {
              bool enabled = updatedTask.recurrence != null && updatedTask.recurrence!.isNotEmpty;

              return TagBox(
                icon: "assets/images/icons/_common/repeat.svg",
                backgroundColor: enabled ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
                active: enabled,
                isBig: true,
                onPressed: () {
                  var cubit = context.read<EditTaskCubit>();

                  cubit.recurrenceTap();

                  showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => RecurrenceModal(
                      onChange: (RecurrenceRule? rule) {
                        cubit.setRecurrence(rule);
                      },
                      selectedRecurrence: updatedTask.recurrenceComputed,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
