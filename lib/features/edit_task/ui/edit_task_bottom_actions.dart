import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';

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
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _button(
            iconAsset: "assets/images/icons/_common/exclamationmark.svg",
            active: false,
            onPressed: () {
              // TODO edit priority
            },
          ),
          const SizedBox(width: 11),
          _button(
            iconAsset: "assets/images/icons/_common/target.svg",
            active: false,
            onPressed: () {
              // TODO edit focus
            },
          ),
          const SizedBox(width: 11),
          _button(
            iconAsset: "assets/images/icons/_common/flags.svg",
            active: false,
            onPressed: () {
              // TODO edit deadline
            },
          ),
          const SizedBox(width: 11),
          _button(
            iconAsset: "assets/images/icons/_common/link.svg",
            active: false,
            onPressed: () {
              // TODO edit link
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
  }) {
    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        height: 32,
        width: 32,
        color: active ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: 22,
            height: 22,
            color: active ? ColorsExt.grey2(context) : ColorsExt.grey3(context),
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
        color: ColorsExt.grey6(context),
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
            break;
          case EditTaskAdditionalAction.snoozeTomorrow:
            context.read<EditTaskCubit>().snooze(
                  DateTime.now().add(const Duration(days: 1)),
                );
            break;
          case EditTaskAdditionalAction.snoozeNextWeek:
            context.read<EditTaskCubit>().snooze(
                  DateTime.now().add(const Duration(days: 7)),
                );
            break;
          case EditTaskAdditionalAction.someday:
            context.read<EditTaskCubit>().setSomeday();
            break;
          case EditTaskAdditionalAction.delete:
            context.read<EditTaskCubit>().delete();
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<EditTaskAdditionalAction>>[
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
