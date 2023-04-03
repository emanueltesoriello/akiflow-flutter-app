import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

class UndoBottomView extends StatelessWidget {
  const UndoBottomView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        if (state.queue.isEmpty) {
          return const SizedBox();
        }
        UndoTask? task = state.queue.first;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 51,
                  margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: Dimension.padding),
                  decoration: BoxDecoration(
                    color: color(context, task.type),
                    border: Border.all(
                      color: ColorsExt.grey4(context),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      icon(context, task.type),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(text(task.type),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500)),
                      ),
                      TextButton(
                          onPressed: () {
                            context.read<TasksCubit>().undo();
                          },
                          child: Text(t.task.undo.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: ColorsExt.akiflow(context), fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + Dimension.bottomBarHeight + Dimension.padding),
          ],
        );
      },
    );
  }

  Color color(BuildContext context, UndoType type) {
    switch (type) {
      case UndoType.delete:
        return ColorsExt.cyan25(context);
      case UndoType.markDone:
        return ColorsExt.green20(context);
      case UndoType.markUndone:
        return ColorsExt.cyan25(context);
      case UndoType.plan:
        return ColorsExt.cyan25(context);
      case UndoType.snooze:
        return ColorsExt.akiflow20(context);
      case UndoType.restore:
        // TODO: Handle this case.
        break;
      case UndoType.moveToInbox:
        return ColorsExt.green20(context);
      case UndoType.updated:
        return ColorsExt.green20(context);
    }
    return ColorsExt.akiflow(context);
  }

  String text(UndoType type) {
    switch (type) {
      case UndoType.delete:
        return 'Task Deleted';
      case UndoType.markDone:
        return 'Marked as done';
      case UndoType.plan:
        return 'Task Planned';
      case UndoType.snooze:
        return 'Task Snoozed';
      case UndoType.markUndone:
        return 'Task Undone';
      case UndoType.moveToInbox:
        return 'Task Updated';

      case UndoType.updated:
        return 'Task Updated';
      case UndoType.restore:
        return 'Task restored';
    }
  }

  SvgPicture icon(BuildContext context, UndoType type) {
    var iconSize = 25.0;
    switch (type) {
      case UndoType.delete:
        return SvgPicture.asset(
          Assets.images.icons.common.trashSVG,
          height: iconSize,
        );

      case UndoType.markDone:
        return SvgPicture.asset(
          Assets.images.icons.common.checkDoneSVG,
          color: ColorsExt.green(context),
          height: iconSize,
        );
      case UndoType.plan:
        return SvgPicture.asset(
          Assets.images.icons.common.calendarSVG,
          color: ColorsExt.cyan(context),
          height: iconSize,
        );
      case UndoType.snooze:
        return SvgPicture.asset(
          Assets.images.icons.common.clockSVG,
          color: ColorsExt.akiflow(context),
          height: iconSize,
        );
      case UndoType.markUndone:
        return SvgPicture.asset(
          Assets.images.icons.common.checkDoneSVG,
          color: ColorsExt.cyan25(context),
          height: iconSize,
        );
      case UndoType.restore:
        // TODO: Handle this case.
        break;
      case UndoType.moveToInbox:
        return SvgPicture.asset(
          Assets.images.icons.common.checkDoneOutlineSVG,
          color: ColorsExt.grey2_5(context),
          height: iconSize,
        );
      case UndoType.updated:
        return SvgPicture.asset(
          Assets.images.icons.common.checkDoneOutlineSVG,
          color: ColorsExt.grey2_5(context),
          height: iconSize,
        );
    }
    return SvgPicture.asset(
      Assets.images.icons.common.calendarSVG,
      color: ColorsExt.akiflow10(context),
      height: iconSize,
    );
  }
}
