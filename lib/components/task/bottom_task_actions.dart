import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/button_action.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';

enum BottomTaskAdditionalActions {
  moveToInbox,
  planForToday,
  setDeadline,
  duplicate,
  markAsDone,
  delete
}

class BottomTaskActions extends StatelessWidget {
  const BottomTaskActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.cyan25(context),
                  topColor: ColorsExt.cyan(context),
                  icon: 'assets/images/icons/_common/calendar.svg',
                  bottomLabel: t.task.plan,
                  click: () {
                    // TODO open calendar and plan
                  },
                ),
              ),
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.pink30(context),
                  topColor: ColorsExt.pink(context),
                  icon: 'assets/images/icons/_common/clock.svg',
                  bottomLabel: t.task.snooze,
                  click: () {
                    // TODO open calendar and snooze
                  },
                ),
              ),
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.grey5(context),
                  topColor: ColorsExt.grey3(context),
                  icon: 'assets/images/icons/_common/number.svg',
                  bottomLabel: t.task.assign,
                  click: () {
                    // TODO open labels and select
                  },
                ),
              ),
              Expanded(
                child: ButtonAction(
                  backColor: ColorsExt.grey5(context),
                  topColor: ColorsExt.grey3(context),
                  icon: 'assets/images/icons/_common/exclamationmark.svg',
                  bottomLabel: t.task.priority,
                  click: () {
                    context.read<TasksCubit>().selectPriority();
                  },
                ),
              ),
              Expanded(
                child: PopupMenuButton<BottomTaskAdditionalActions>(
                  icon: SvgPicture.asset(
                    "assets/images/icons/_common/ellipsis.svg",
                    width: 26,
                    height: 26,
                    color: ColorsExt.grey2(context),
                  ),
                  onSelected: (BottomTaskAdditionalActions result) {
                    switch (result) {
                      case BottomTaskAdditionalActions.moveToInbox:
                        context.read<TasksCubit>().moveToInbox();
                        break;
                      case BottomTaskAdditionalActions.planForToday:
                        context.read<TasksCubit>().planFor(DateTime.now());
                        break;
                      case BottomTaskAdditionalActions.setDeadline:
                        context.read<TasksCubit>().setDeadline();
                        break;
                      case BottomTaskAdditionalActions.duplicate:
                        context.read<TasksCubit>().duplicate();
                        break;
                      case BottomTaskAdditionalActions.markAsDone:
                        context.read<TasksCubit>().markAsDone();
                        break;
                      case BottomTaskAdditionalActions.delete:
                        context.read<TasksCubit>().delete();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<BottomTaskAdditionalActions>>[
                    PopupMenuItem<BottomTaskAdditionalActions>(
                      value: BottomTaskAdditionalActions.moveToInbox,
                      child: _additionalActionMenuItem(
                        context,
                        iconAsset: "assets/images/icons/_common/tray.svg",
                        text: t.task.moveToInbox,
                      ),
                    ),
                    PopupMenuItem<BottomTaskAdditionalActions>(
                      value: BottomTaskAdditionalActions.planForToday,
                      child: _additionalActionMenuItem(
                        context,
                        iconAsset:
                            "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                        text: t.task.planForToday,
                      ),
                    ),
                    PopupMenuItem<BottomTaskAdditionalActions>(
                      value: BottomTaskAdditionalActions.setDeadline,
                      child: _additionalActionMenuItem(
                        context,
                        iconAsset: "assets/images/icons/_common/flags.svg",
                        text: t.task.setDeadline,
                      ),
                    ),
                    PopupMenuItem<BottomTaskAdditionalActions>(
                      value: BottomTaskAdditionalActions.duplicate,
                      child: _additionalActionMenuItem(
                        context,
                        iconAsset:
                            "assets/images/icons/_common/square_on_square.svg",
                        text: t.task.duplicate,
                      ),
                    ),
                    PopupMenuItem<BottomTaskAdditionalActions>(
                      value: BottomTaskAdditionalActions.markAsDone,
                      child: _additionalActionMenuItem(
                        context,
                        iconAsset:
                            "assets/images/icons/_common/Check-done-outline.svg",
                        text: t.task.markAsDone,
                      ),
                    ),
                    PopupMenuItem<BottomTaskAdditionalActions>(
                      value: BottomTaskAdditionalActions.delete,
                      child: _additionalActionMenuItem(
                        context,
                        iconAsset: "assets/images/icons/_common/trash.svg",
                        text: t.task.delete,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
