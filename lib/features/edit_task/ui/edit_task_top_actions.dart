import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/task/plan_for_action.dart';
import 'package:mobile/features/add_task/ui/add_task_action_item.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/recurrence_modal.dart';
import 'package:mobile/features/plan_modal/ui/plan_modal.dart';
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
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          PlanForAction(
            task: context.watch<EditTaskCubit>().state.newTask,
            onTap: () {
              EditTaskCubit cubit = context.read<EditTaskCubit>();

              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: PlanModal(
                    onSelectDate: (
                        {required DateTime? date, required DateTime? datetime, required TaskStatusType statusType}) {
                      cubit.planFor(date, dateTime: datetime, statusType: statusType, update: true);
                    },
                    setForInbox: () {
                      cubit.planFor(null, statusType: TaskStatusType.inbox, update: true);
                    },
                    setForSomeday: () {
                      cubit.planFor(null, statusType: TaskStatusType.someday, update: true);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              Task task = state.newTask;

              String? text;

              if (task.duration != null) {
                double hours = state.selectedDuration ?? 4;
                double minutes = (hours - hours.floor()) * 60;

                text = "${hours.floor()}h${minutes.floor()}m";
              }

              return AddTaskActionItem(
                leadingIconAsset: "assets/images/icons/_common/hourglass.svg",
                color: ColorsExt.grey6(context),
                active: task.duration != null,
                text: text,
                onPressed: () {},
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              return AddTaskActionItem(
                leadingIconAsset: "assets/images/icons/_common/repeat.svg",
                color: state.newTask.recurrence != null && state.newTask.recurrence!.isNotEmpty
                    ? ColorsExt.grey6(context)
                    : ColorsExt.grey3(context),
                active: state.newTask.recurrence != null && state.newTask.recurrence!.isNotEmpty,
                onPressed: () {
                  var cubit = context.read<EditTaskCubit>();

                  showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => RecurrenceModal(
                      onChange: (RecurrenceRule? rule) {
                        cubit.setRecurrence(rule);
                      },
                      selectedRecurrence: state.newTask.recurrenceComputed,
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
