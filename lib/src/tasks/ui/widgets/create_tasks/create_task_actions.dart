import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_js/quickjs/ffi.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
import 'package:mobile/src/base/ui/widgets/task/plan_for_action.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/duration_cupertino_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/labels_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/plan_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/change_priority_modal.dart';

import '../../../../../assets.dart';
import '../../../../../common/style/colors.dart';
import '../../../../../extensions/task_extension.dart';

class CreateTaskActions extends StatefulWidget {
  const CreateTaskActions(
      {Key? key,
      required this.titleController,
      required this.titleFocus,
      this.backgroundPlanColor,
      this.borderPlanColor})
      : super(key: key);
  final TextEditingController titleController;
  final FocusNode titleFocus;
  final Color? backgroundPlanColor;
  final Color? borderPlanColor;

  @override
  State<CreateTaskActions> createState() => _CreateTaskActionsState();
}

class _CreateTaskActionsState extends State<CreateTaskActions> {
  var isFirstSet = true;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Wrap(
        runSpacing: Dimension.paddingS,
        children: [
          PlanForAction(
            backgroundPlanColor: widget.backgroundPlanColor,
            borderPlanColor: widget.borderPlanColor,
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
                icon: Assets.images.icons.common.hourglassSVG,
                active: task.duration != null && task.duration != 0,
                foregroundColor: ColorsExt.grey800(context),
                backgroundColor: task.duration != null && task.duration != 0
                    ? ColorsExt.grey100(context)
                    : ColorsExt.grey50(context),
                isSquare: task.duration != null && task.duration != 0 ? false : true,
                isBig: true,
                text: text,
                onPressed: () {
                  showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => DurationCupertinoModal(
                      state: state,
                      onConfirm: (int duration) => context.read<EditTaskCubit>().setDuration(duration, fromModal: true),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: Dimension.paddingS),
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
                backgroundColor: task.priority != null ? ColorsExt.grey100(context) : ColorsExt.grey50(context),
                isSquare: true,
                isBig: true,
                text: text,
                onPressed: () async {
                  PriorityEnum currentPriority = PriorityEnum.fromValue(task.priority);
                  EditTaskCubit cubit = context.read<EditTaskCubit>();

                  cubit.priorityTap();

                  PriorityEnum? newPriority = await showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => PriorityModal(currentPriority),
                    closeProgressThreshold: 0,
                    expand: false,
                  );

                  cubit.setPriority(newPriority);
                },
              );
            },
          ),
          const SizedBox(width: Dimension.paddingS),
          Builder(
            builder: (context) {
              final editTaskCubit = context.read<EditTaskCubit>();
              final task = editTaskCubit.state.updatedTask;
              final labels = context.read<LabelsCubit>().state.labels;
              Color? background;
              final label = task.listId != null
                  ? labels.firstWhereOrNull(
                      (label) => task.listId!.contains(label.id!),
                    )
                  : null;
              if (label?.color != null) {
                background = ColorsExt.getFromName(label!.color!);
              }

              return TagBox(
                isBig: true,
                icon: Assets.images.icons.common.numberSVG,
                text: label?.title ?? t.editTask.addLabel,
                foregroundColor: background ?? ColorsExt.grey700(context),
                backgroundColor: background != null ? background.withOpacity(0.1) : ColorsExt.grey50(context),
                iconColor: label?.color != null ? ColorsExt.getFromName(label!.color!) : ColorsExt.grey600(context),
                active: label?.color != null,
                onPressed: () {
                  showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => LabelsModal(
                      selectLabel: (Label label) {
                        editTaskCubit.setLabel(label);
                      },
                      showNoLabel: task.listId != null,
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
