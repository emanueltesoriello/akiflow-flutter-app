import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/deadline_modal.dart';
import 'package:mobile/features/edit_task/ui/actions/links_modal.dart';
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
          _button(
            iconAsset: "assets/images/icons/_common/exclamationmark.svg",
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
            active: task.priority != null && task.priority != 0,
            onPressed: () {
              context.read<EditTaskCubit>().changePriority();
            },
          ),
          const SizedBox(width: 11),
          _button(
            iconAsset: "assets/images/icons/_common/target.svg",
            active: task.dailyGoal != null && task.dailyGoal == 1,
            onPressed: () {
              context.read<EditTaskCubit>().toggleDailyGoal();
            },
          ),
          const SizedBox(width: 11),
          _button(
            iconAsset: "assets/images/icons/_common/flags.svg",
            active: task.dueDate != null,
            text: task.dueDateFormatted,
            onPressed: () {
              var cubit = context.read<EditTaskCubit>();

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
          _button(
            iconAsset: "assets/images/icons/_common/link.svg",
            active: () {
              try {
                return task.links!.toList().isNotEmpty && task.links!.toList().every((element) => element.isNotEmpty);
              } catch (e) {
                return false;
              }
            }(),
            onPressed: () {
              var cubit = context.read<EditTaskCubit>();

              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: const LinksModal(),
                ),
              );
            },
          ),
          const Spacer(),
          _menu(context),
        ],
      ),
    );
  }

  Widget _button({
    required String iconAsset,
    required bool active,
    required Function() onPressed,
    String? text,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 32,
          minWidth: 28,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: active ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 22,
                  height: 22,
                  color: iconColor ?? (active ? ColorsExt.grey2(context) : ColorsExt.grey3(context)),
                ),
                Builder(builder: (context) {
                  if (text == null) {
                    return const SizedBox();
                  } else {
                    return Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(text),
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ),
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
        switch (result) {
          case EditTaskAdditionalAction.duplicate:
            context.read<EditTaskCubit>().duplicate();
            Navigator.pop(context);
            break;
          case EditTaskAdditionalAction.snoozeTomorrow:
            context.read<EditTaskCubit>().planFor(
                  DateTime.now().add(const Duration(days: 1)),
                  statusType: TaskStatusType.snoozed,
                );
            break;
          case EditTaskAdditionalAction.snoozeNextWeek:
            context.read<EditTaskCubit>().planFor(
                  DateTime.now().add(const Duration(days: 7)),
                  statusType: TaskStatusType.snoozed,
                );
            break;
          case EditTaskAdditionalAction.someday:
            context.read<EditTaskCubit>().planFor(
                  null,
                  statusType: TaskStatusType.someday,
                );
            break;
          case EditTaskAdditionalAction.delete:
            context.read<EditTaskCubit>().delete();
            Navigator.pop(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<EditTaskAdditionalAction>>[
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.duplicate,
          child: _additionalActionMenuItem(
            context,
            iconAsset: "assets/images/icons/_common/square_on_square.svg",
            text: t.task.duplicate,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.snoozeTomorrow,
          child: _additionalActionMenuItem(
            context,
            iconAsset: "assets/images/icons/_common/clock.svg",
            text: t.task.snoozeTomorrow,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.snoozeNextWeek,
          child: _additionalActionMenuItem(
            context,
            iconAsset: "assets/images/icons/_common/clock.svg",
            text: t.task.snoozeNextWeek,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.someday,
          child: _additionalActionMenuItem(
            context,
            iconAsset: "assets/images/icons/_common/tray.svg",
            text: t.task.someday,
          ),
        ),
        PopupMenuItem<EditTaskAdditionalAction>(
          value: EditTaskAdditionalAction.delete,
          child: _additionalActionMenuItem(
            context,
            iconAsset: "assets/images/icons/_common/trash.svg",
            text: t.task.delete,
          ),
        ),
      ],
    );
  }

  Widget _additionalActionMenuItem(
    BuildContext context, {
    required String iconAsset,
    required String text,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 22,
          height: 22,
          color: ColorsExt.grey2(context),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
