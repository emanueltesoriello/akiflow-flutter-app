import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

class UndoBottomView extends StatefulWidget {
  const UndoBottomView({
    Key? key,
  }) : super(key: key);

  @override
  State<UndoBottomView> createState() => _UndoBottomViewState();
}

class _UndoBottomViewState extends State<UndoBottomView> {
  int snackBarShown = 0;

  _buildSnackBarAfterUndoneClick() {
    return SnackBar(
      elevation: 0,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(bottom: Dimension.padding),
        child: Container(
          height: Dimension.snackBarHeight,
          margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
          width: double.infinity,
          padding: const EdgeInsets.only(left: Dimension.padding),
          decoration: BoxDecoration(
            color: ColorsExt.jordyBlue100(context),
            border: Border.all(
              color: ColorsExt.grey300(context),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(Dimension.radiusS),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                Assets.images.icons.common.checkDoneOutlineSVG,
                color: ColorsExt.grey700(context),
                height: 25.0,
              ),
              const SizedBox(width: Dimension.paddingS),
              Expanded(
                child: Text("Action undone",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w500)),
              ),
              TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: Text("CLOSE",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: ColorsExt.akiflow500(context), fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }

  _buildSnackBar(UndoTask task) {
    return SnackBar(
      elevation: 0,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(bottom: Dimension.padding),
        child: Container(
          height: Dimension.snackBarHeight,
          margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
          width: double.infinity,
          padding: const EdgeInsets.only(left: Dimension.padding),
          decoration: BoxDecoration(
            color: color(context, task.type),
            border: Border.all(
              color: ColorsExt.grey300(context),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(Dimension.radiusS),
          ),
          child: Row(
            children: [
              icon(context, task.type),
              const SizedBox(width: Dimension.paddingS),
              Expanded(
                child: Text(text(task.type),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w500)),
              ),
              TextButton(
                  onPressed: () {
                    context.read<TasksCubit>().undo();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(_buildSnackBarAfterUndoneClick());
                  },
                  child: Text(t.task.undo.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: ColorsExt.akiflow500(context), fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksCubit, TasksCubitState>(
        listener: (context, state) {
          if (state.queue.isNotEmpty && snackBarShown == 0) {
            snackBarShown += 1;

            UndoTask? task = state.queue.first;

            ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(task));
          } else if (state.queue.isEmpty) {
            snackBarShown = 0;
          }
        },
        child: const SizedBox());
  }

  Color color(BuildContext context, UndoType type) {
    switch (type) {
      case UndoType.delete:
        return ColorsExt.jordyBlue100(context);
      case UndoType.markDone:
        return ColorsExt.yorkGreen100(context);
      case UndoType.markUndone:
        return ColorsExt.jordyBlue100(context);
      case UndoType.plan:
        return ColorsExt.jordyBlue100(context);
      case UndoType.snooze:
        return ColorsExt.akiflow200(context);
      case UndoType.restore:
        // TODO: Handle this case.
        break;
      case UndoType.moveToInbox:
        return ColorsExt.yorkGreen100(context);
      case UndoType.updated:
        return ColorsExt.yorkGreen100(context);
    }
    return ColorsExt.akiflow500(context);
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
          color: ColorsExt.yorkGreen400(context),
          height: iconSize,
        );
      case UndoType.plan:
        return SvgPicture.asset(
          Assets.images.icons.common.calendarSVG,
          color: ColorsExt.jordyBlue400(context),
          height: iconSize,
        );
      case UndoType.snooze:
        return SvgPicture.asset(
          Assets.images.icons.common.clockSVG,
          color: ColorsExt.akiflow500(context),
          height: iconSize,
        );
      case UndoType.markUndone:
        return SvgPicture.asset(
          Assets.images.icons.common.checkDoneSVG,
          color: ColorsExt.jordyBlue200(context),
          height: iconSize,
        );
      case UndoType.restore:
        // TODO: Handle this case.
        break;
      case UndoType.moveToInbox:
        return SvgPicture.asset(
          Assets.images.icons.common.checkDoneOutlineSVG,
          color: ColorsExt.grey700(context),
          height: iconSize,
        );
      case UndoType.updated:
        return SvgPicture.asset(
          Assets.images.icons.common.checkDoneOutlineSVG,
          color: ColorsExt.grey700(context),
          height: iconSize,
        );
    }
    return SvgPicture.asset(
      Assets.images.icons.common.calendarSVG,
      color: ColorsExt.akiflow100(context),
      height: iconSize,
    );
  }
}
