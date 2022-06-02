import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/popup_menu_item.dart';
import 'package:mobile/components/base/tagbox.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/deadline_modal.dart';
import 'package:mobile/features/edit_task/ui/actions/links_modal.dart';
import 'package:mobile/features/edit_task/ui/change_priority_modal.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/task/task.dart';

enum EditTaskAdditionalAction {
  duplicate,
  snoozeTomorrow,
  snoozeNextWeek,
  someday,
  delete,
}

class EditTaskBottomActions extends StatefulWidget {
  const EditTaskBottomActions({Key? key}) : super(key: key);

  @override
  State<EditTaskBottomActions> createState() => _EditTaskBottomActionsState();
}

class _EditTaskBottomActionsState extends State<EditTaskBottomActions> {
  @override
  Widget build(BuildContext context) {
    Task task = context.watch<EditTaskCubit>().state.updatedTask;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          TagBox(
            icon: "assets/images/icons/_common/exclamationmark.svg",
            isBig: true,
            isSquare: true,
            iconColor: () {
              switch (task.priority) {
                case 1:
                  return ColorsExt.red(context);
                case 2:
                  return ColorsExt.yellow(context);
                case 3:
                  return ColorsExt.green(context);
                default:
                  return ColorsExt.grey3(context);
              }
            }(),
            backgroundColor:
                task.priority != null && task.priority != 0 ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
            active: task.priority != null && task.priority != 0,
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
          ),
          const SizedBox(width: 11),
          TagBox(
            icon: "assets/images/icons/_common/target.svg",
            isBig: true,
            isSquare: true,
            backgroundColor:
                task.dailyGoal != null && task.dailyGoal == 1 ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
            active: task.dailyGoal != null && task.dailyGoal == 1,
            onPressed: () {
              context.read<EditTaskCubit>().toggleDailyGoal();
            },
          ),
          const SizedBox(width: 11),
          TagBox(
            icon: "assets/images/icons/_common/flags.svg",
            isBig: true,
            isSquare: true,
            backgroundColor: task.dueDate != null ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
            active: task.dueDate != null,
            text: task.dueDateFormatted,
            onPressed: () {
              var cubit = context.read<EditTaskCubit>();

              cubit.deadlineTap();

              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: DeadlineModal(
                    initialDate: () {
                      try {
                        return DateTime.tryParse(context.watch<EditTaskCubit>().state.updatedTask.dueDate!);
                      } catch (_) {
                        return null;
                      }
                    }(),
                    onSelectDate: (DateTime? date) {
                      cubit.setDeadline(date);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 11),
          Builder(builder: (context) {
            bool active = false;

            try {
              if (task.links!.toList().isNotEmpty && task.links!.toList().every((element) => element.isNotEmpty)) {
                active = true;
              }
            } catch (_) {}

            return TagBox(
              icon: "assets/images/icons/_common/link.svg",
              isBig: true,
              isSquare: true,
              active: active,
              backgroundColor: active ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
              onPressed: () {
                var cubit = context.read<EditTaskCubit>();

                cubit.linksTap();

                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => BlocProvider.value(
                    value: cubit,
                    child: const LinksModal(),
                  ),
                );
              },
            );
          }),
          const Spacer(),
          _menu(context),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return PopupMenuButton<EditTaskAdditionalAction>(
      icon: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: ColorsExt.grey6(context),
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/images/icons/_common/ellipsis.svg",
            width: 22,
            height: 22,
            color: ColorsExt.grey2(context),
          ),
        ),
      ),
      onSelected: (EditTaskAdditionalAction result) {
        EditTaskCubit cubit = context.read<EditTaskCubit>();

        cubit.menuTap();

        switch (result) {
          case EditTaskAdditionalAction.duplicate:
            cubit.duplicate();
            Navigator.pop(context);
            break;
          case EditTaskAdditionalAction.snoozeTomorrow:
            cubit.planFor(
              DateTime.now().add(const Duration(days: 1)),
              statusType: TaskStatusType.snoozed,
            );
            break;
          case EditTaskAdditionalAction.snoozeNextWeek:
            cubit.planFor(
              DateTime.now().add(const Duration(days: 7)),
              statusType: TaskStatusType.snoozed,
            );
            break;
          case EditTaskAdditionalAction.someday:
            cubit.planFor(
              null,
              statusType: TaskStatusType.someday,
            );
            break;
          case EditTaskAdditionalAction.delete:
            cubit.delete();
            Navigator.pop(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<EditTaskAdditionalAction>>[
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.duplicate,
          child: PopupMenuCustomItem(
            iconAsset: "assets/images/icons/_common/square_on_square.svg",
            text: t.task.duplicate,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.snoozeTomorrow,
          child: PopupMenuCustomItem(
            iconAsset: "assets/images/icons/_common/clock.svg",
            text: t.task.snoozeTomorrow,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.snoozeNextWeek,
          child: PopupMenuCustomItem(
            iconAsset: "assets/images/icons/_common/clock.svg",
            text: t.task.snoozeNextWeek,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.someday,
          child: PopupMenuCustomItem(
            iconAsset: "assets/images/icons/_common/tray.svg",
            text: t.task.someday,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.delete,
          child: PopupMenuCustomItem(
            iconAsset: "assets/images/icons/_common/trash.svg",
            text: t.task.delete,
          ),
        ),
      ],
    );
  }
}
