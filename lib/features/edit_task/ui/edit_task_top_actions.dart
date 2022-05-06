import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/add_task/ui/add_task_action_item.dart';
import 'package:mobile/features/add_task/ui/plan_modal.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

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
                onPressed: () {
                  // TODO edit duration
                },
              );
            },
          ),
          const SizedBox(width: 8),
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

        if (state.planType == EditTaskPlanType.plan) {
          color = ColorsExt.cyan25(context);
          leadingIconAsset = "assets/images/icons/_common/calendar.svg";
        } else {
          color = ColorsExt.pink30(context);
          leadingIconAsset = "assets/images/icons/_common/clock.svg";
        }

        if (state.newTask.date != null) {
          if (state.newTask.datetime != null) {
            if (state.newTask.isToday) {
              text = DateFormat("HH:mm").format(state.newTask.date!.toLocal());
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw +
                  DateFormat(" - HH:mm").format(state.newTask.date!.toLocal());
            } else {
              text = DateFormat("EEE, d MMM")
                  .format(state.newTask.date!.toLocal());
            }
          } else {
            if (state.newTask.isToday) {
              text = t.addTask.today;
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw;
            } else {
              text = DateFormat("EEE, d MMM")
                  .format(state.newTask.date!.toLocal());
            }
          }
        } else if (state.newTask.status == TaskStatusType.someday.id) {
          text = t.addTask.someday;
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

            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => BlocProvider.value(
                value: cubit,
                child: const PlanModal(updateTasksAfterSelected: true),
              ),
            );
          },
        );
      },
    );
  }
}
