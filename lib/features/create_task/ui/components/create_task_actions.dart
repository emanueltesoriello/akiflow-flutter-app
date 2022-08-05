import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

import '../../../../assets.dart';
import '../../../../components/base/tagbox.dart';
import '../../../../components/task/plan_for_action.dart';
import '../../../../style/colors.dart';
import '../../../../utils/task_extension.dart';
import '../../../edit_task/cubit/edit_task_cubit.dart';
import '../../../edit_task/ui/actions/plan_modal.dart';
import '../../../label/cubit/labels_cubit.dart';

class CreateTaskActions extends StatelessWidget {
  const CreateTaskActions({Key? key, required this.titleController, required this.titleFocus})
      : super(key: key);
  final TextEditingController titleController;
  final FocusNode titleFocus;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Wrap(
        runSpacing: 8,
        children: [
          PlanForAction(
            task: context.watch<EditTaskCubit>().state.updatedTask,
            onTap: () {
              var editTaskCubit = context.read<EditTaskCubit>();

              editTaskCubit.planTap();

              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => PlanModal(
                  initialDate: editTaskCubit.state.updatedTask.date != null
                      ? DateTime.parse(editTaskCubit.state.updatedTask.date!)
                      : DateTime.now(),
                  initialDatetime: editTaskCubit.state.updatedTask.datetime != null
                      ? DateTime.parse(editTaskCubit.state.updatedTask.datetime!)
                      : null,
                  taskStatusType: editTaskCubit.state.updatedTask.statusType ?? TaskStatusType.inbox,
                  onSelectDate: (
                      {required DateTime? date,
                      required DateTime? datetime,
                      required TaskStatusType statusType}) async {
                    editTaskCubit.planFor(date, dateTime: datetime, statusType: statusType);

                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      titleFocus.requestFocus();
                    });
                  },
                  setForInbox: () {
                    editTaskCubit.planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
                  },
                  setForSomeday: () {
                    editTaskCubit.planFor(null, dateTime: null, statusType: TaskStatusType.someday);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              Task task = state.updatedTask;

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
                active: task.duration != null && task.duration != 0,
                backgroundColor:
                    task.duration != null && task.duration != 0 ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
                isSquare: task.duration != null && task.duration != 0 ? false : true,
                isBig: true,
                text: text,
                onPressed: () {
                  context.read<EditTaskCubit>().toggleDuration();
                },
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              Task task = state.updatedTask;

              String image;
              switch (task.priority) {
                case 1:
                  image = Assets.images.icons.common.priorityHighSVG;
                  break;
                case 2:
                  image = Assets.images.icons.common.priorityMidSVG;
                  break;
                case 3:
                  image = Assets.images.icons.common.priorityLowSVG;
                  break;
                case null:
                  image = Assets.images.icons.common.importanceGreySVG;
                  break;
                default:
                  image = Assets.images.icons.common.importanceGreySVG;
                  break;
              }
              String? text;

              return TagBox(
                icon: image,
                active: task.priority != null,
                backgroundColor: task.priority != null ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
                isSquare: true,
                isBig: true,
                text: text,
                onPressed: () {
                  context.read<EditTaskCubit>().toggleImportance();
                },
              );
            },
          ),
          const SizedBox(width: 8),
          BlocBuilder<EditTaskCubit, EditTaskCubitState>(
            builder: (context, state) {
              Color? background;

              List<Label> labels = context.read<LabelsCubit>().state.labels;

              Label? label;

              try {
                label = labels.firstWhere((label) => state.updatedTask.listId!.contains(label.id!));
              } catch (_) {}

              if (label?.color != null) {
                background = ColorsExt.getFromName(label!.color!);
              }

              return TagBox(
                icon: Assets.images.icons.common.numberSVG,
                active: state.updatedTask.listId != null,
                iconColor: background ?? ColorsExt.grey2(context),
                backgroundColor: background != null ? background.withOpacity(0.1) : ColorsExt.grey7(context),
                text: label?.title ?? t.addTask.label,
                isBig: true,
                onPressed: () {
                  context.read<EditTaskCubit>().toggleLabels();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
