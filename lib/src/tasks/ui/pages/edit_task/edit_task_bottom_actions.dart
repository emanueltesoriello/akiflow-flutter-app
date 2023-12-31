import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/change_priority_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/create_link_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/deadline_modal.dart';
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
      // padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const SizedBox(width: 16),
            TagBox(
              icon: () {
                switch (task.priority) {
                  case 1:
                    return Assets.images.icons.common.priorityHighSVG;
                  case 2:
                    return Assets.images.icons.common.priorityMidSVG;
                  case 3:
                    return Assets.images.icons.common.priorityLowSVG;
                  case null:
                    return Assets.images.icons.common.importanceGreySVG;
                  default:
                    return Assets.images.icons.common.importanceGreySVG;
                }
              }(),
              isBig: true,
              isSquare: true,
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
              icon: Assets.images.icons.common.targetActiveSVG,
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
              icon: Assets.images.icons.common.flagSVG,
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
            const SizedBox(width: Dimension.paddingS),
            Builder(builder: (context) {
              bool active = false;

              try {
                if (task.links!.toList().isNotEmpty && task.links!.toList().every((element) => element.isNotEmpty)) {
                  active = true;
                }
              } catch (_) {}

              return TagBox(
                icon: Assets.images.icons.common.linkSVG,
                iconSize: 19.5,
                isBig: true,
                isSquare: true,
                active: active,
                backgroundColor: active ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
                onPressed: () async {
                  var cubit = context.read<EditTaskCubit>();

                  cubit.linksTap();

                  String? newLink = await showCupertinoModalBottomSheet(
                    context: context,
                    builder: (context) => const CreateLinkModal(),
                  );

                  if (newLink != null) {
                    if (newLink.contains('//')) {
                      cubit.addLink(newLink);
                    } else {
                      cubit.addLink('http://$newLink');
                    }
                  }
                },
              );
            }),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: Dimension.paddingXS),
            child: _menu(context),
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
      child: PopupMenuButton<EditTaskAdditionalAction>(
        icon: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: ColorsExt.grey6(context),
          ),
          child: Center(
            child: SvgPicture.asset(
              Assets.images.icons.common.ellipsisSVG,
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
              iconAsset: Assets.images.icons.common.squareOnSquareSVG,
              text: t.task.duplicate,
            ),
          ),
          PopupMenuItem<EditTaskAdditionalAction>(
            value: EditTaskAdditionalAction.snoozeTomorrow,
            child: PopupMenuCustomItem(
              iconAsset: Assets.images.icons.common.clockSVG,
              text: t.task.snoozeTomorrow,
            ),
          ),
          PopupMenuItem<EditTaskAdditionalAction>(
            value: EditTaskAdditionalAction.snoozeNextWeek,
            child: PopupMenuCustomItem(
              iconAsset: Assets.images.icons.common.clockSVG,
              text: t.task.snoozeNextWeek,
            ),
          ),
          PopupMenuItem<EditTaskAdditionalAction>(
            value: EditTaskAdditionalAction.someday,
            child: PopupMenuCustomItem(
              iconAsset: Assets.images.icons.common.traySVG,
              text: t.task.someday,
            ),
          ),
          PopupMenuItem<EditTaskAdditionalAction>(
            value: EditTaskAdditionalAction.delete,
            child: PopupMenuCustomItem(
              iconAsset: Assets.images.icons.common.trashSVG,
              text: t.task.delete,
            ),
          ),
        ],
      ),
    );
  }
}
