import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
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
          _plannedFor(context),
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

  Widget _plannedFor(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        String leadingIconAsset;
        String text;
        Color color;

        TaskStatusType? status = TaskStatusTypeExt.fromId(state.newTask.status) ?? TaskStatusType.inbox;

        if ((status == TaskStatusType.inbox || status == TaskStatusType.planned) && status != TaskStatusType.someday) {
          color = ColorsExt.cyan25(context);
          leadingIconAsset = "assets/images/icons/_common/calendar.svg";
        } else {
          color = ColorsExt.pink30(context);
          leadingIconAsset = "assets/images/icons/_common/clock.svg";
        }

        if (state.newTask.date != null) {
          DateTime parsed = DateTime.parse(state.newTask.date!);

          if (state.newTask.datetime != null) {
            if (state.newTask.isToday) {
              text = DateFormat("HH:mm").format(parsed.toLocal());
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw + DateFormat(" - HH:mm").format(parsed.toLocal());
            } else {
              text = DateFormat("EEE, d MMM").format(parsed.toLocal());
            }
          } else {
            if (state.newTask.isToday) {
              text = t.addTask.today;
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw;
            } else {
              text = DateFormat("EEE, d MMM").format(parsed.toLocal());
            }
          }
        } else if (state.newTask.status == TaskStatusType.someday.id) {
          text = t.task.someday;
        } else {
          text = t.bottomBar.inbox;
        }

        return AddTaskActionItem(
          text: text,
          color: color,
          leadingIconAsset: leadingIconAsset,
          active: true,
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();

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
        );
      },
    );
  }
}
