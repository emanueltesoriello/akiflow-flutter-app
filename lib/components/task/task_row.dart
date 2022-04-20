import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/aki_chip.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:mobile/utils/string_ext.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class TaskRow extends StatelessWidget {
  final Task task;
  final Function() completedClick;
  final Function() planClick;
  final Function() selectLabelClick;
  final Function() snoozeClick;
  final bool hideInboxLabel;

  const TaskRow({
    Key? key,
    required this.task,
    required this.completedClick,
    required this.planClick,
    required this.selectLabelClick,
    required this.snoozeClick,
    this.hideInboxLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      groupTag: "task",
      startActionPane: _startActions(context),
      endActionPane: _endActions(context),
      child: Container(
        constraints: const BoxConstraints(minHeight: 78),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _completeCheckbox(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _firstLine(context),
                  _secondLine(context),
                  Builder(builder: (context) {
                    if (task.statusType == null &&
                        !task.isOverdue &&
                        task.listId == null &&
                        !hideInboxLabel) {
                      return const SizedBox();
                    }

                    return const SizedBox(height: 10.5);
                  }),
                  _thirdLine(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Wrap _thirdLine(BuildContext context) {
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _overdue(context),
        Builder(builder: (context) {
          if (task.statusType == null) {
            return const SizedBox();
          }
          if (task.statusType == TaskStatusType.inbox && hideInboxLabel) {
            return const SizedBox();
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _status(context),
              const SizedBox(width: 4),
            ],
          );
        }),
        _label(context),
      ],
    );
  }

  Text _firstLine(BuildContext context) {
    return Text(
      task.title ?? "",
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color:
            task.statusType == TaskStatusType.deleted || task.deletedAt != null
                ? ColorsExt.grey3(context)
                : ColorsExt.grey1(context),
      ),
    );
  }

  InkWell _completeCheckbox() {
    return InkWell(
      onTap: completedClick,
      child: Builder(builder: (context) {
        bool completed = task.isCompletedComputed;

        return SvgPicture.asset(
          completed || (task.temporaryDone ?? false)
              ? "assets/images/icons/_common/Check-done.svg"
              : "assets/images/icons/_common/Check-empty.svg",
          width: 20,
          height: 20,
          color: completed || (task.temporaryDone ?? false)
              ? ColorsExt.grey2(context)
              : ColorsExt.grey3(context),
        );
      }),
    );
  }

  ActionPane _startActions(BuildContext context) {
    return ActionPane(
      motion: const ScrollMotion(),
      extentRatio: 0.3,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                ),
                BoxShadow(
                  offset: const Offset(2, 4),
                  blurRadius: 16,
                  color: ColorsExt.grey7(context),
                ),
              ],
            ),
            width: double.infinity,
            height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Builder(builder: (context) {
                    return _slidableActionLabel(
                      backColor: ColorsExt.green20(context),
                      topColor: ColorsExt.green(context),
                      icon: 'assets/images/icons/_common/Check-done.svg',
                      label: t.task.done.toUpperCase(),
                      click: () {
                        Slidable.of(context)?.close();
                        completedClick();
                      },
                    );
                  }),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ActionPane _endActions(BuildContext context) {
    return ActionPane(
      dismissible: DismissiblePane(onDismissed: () {}),
      motion: const ScrollMotion(),
      extentRatio: 0.6,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                ),
                BoxShadow(
                  offset: const Offset(2, 4),
                  blurRadius: 16,
                  color: ColorsExt.grey7(context),
                ),
              ],
            ),
            width: double.infinity,
            height: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 16),
                Builder(builder: (context) {
                  return _slidableAction(
                    backColor: ColorsExt.grey5(context),
                    topColor: ColorsExt.grey3(context),
                    icon: 'assets/images/icons/_common/number.svg',
                    click: () {
                      Slidable.of(context)?.close();
                      selectLabelClick();
                    },
                  );
                }),
                const SizedBox(width: 16),
                Builder(builder: (context) {
                  return _slidableAction(
                    backColor: ColorsExt.pink30(context),
                    topColor: ColorsExt.pink(context),
                    icon: 'assets/images/icons/_common/clock.svg',
                    click: () {
                      Slidable.of(context)?.close();
                      snoozeClick();
                    },
                  );
                }),
                const SizedBox(width: 16),
                Expanded(
                  child: Builder(builder: (context) {
                    return _slidableActionLabel(
                      backColor: ColorsExt.cyan25(context),
                      topColor: ColorsExt.cyan(context),
                      icon: 'assets/images/icons/_common/calendar.svg',
                      label: t.task.plan.toUpperCase(),
                      click: () {
                        Slidable.of(context)?.close();
                        planClick();
                      },
                    );
                  }),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _slidableAction({
    required Color backColor,
    required Color topColor,
    required String icon,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Center(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backColor,
          ),
          child: Center(
            child: SvgPicture.asset(
              icon,
              color: topColor,
              width: 21,
              height: 21,
            ),
          ),
        ),
      ),
    );
  }

  Widget _slidableActionLabel({
    required Color backColor,
    required Color topColor,
    required String icon,
    required String label,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Center(
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: SvgPicture.asset(
                  icon,
                  color: topColor,
                  width: 21,
                  height: 21,
                ),
              ),
              const SizedBox(width: 4.5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: topColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overdue(BuildContext context) {
    if (task.isOverdue) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/icons/_common/Clock_alert.svg",
            width: 20,
            height: 20,
            color: ColorsExt.red(context),
          ),
          const SizedBox(width: 4),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _status(BuildContext context) {
    void statusClick() {
      print(task.status);
    }

    if (task.deletedAt != null ||
        task.statusType == TaskStatusType.deleted ||
        task.statusType == TaskStatusType.permanentlyDeleted) {
      return AkiChip(
        icon: "assets/images/icons/_common/trash.svg",
        backgroundColor: ColorsExt.grey6(context),
        text: task.statusType!.name.capitalizeFirstCharacter(),
        onPressed: statusClick,
        foregroundColor: ColorsExt.grey3(context),
      );
    }

    if (task.isCompletedComputed) {
      return AkiChip(
        backgroundColor: ColorsExt.green20(context),
        text: task.doneAtFormatted,
        onPressed: statusClick,
      );
    }

    switch (task.statusType) {
      case TaskStatusType.someday:
        return AkiChip(
          icon: "assets/images/icons/_common/archivebox.svg",
          backgroundColor: ColorsExt.akiflow10(context),
          text: task.statusType!.name.capitalizeFirstCharacter(),
          onPressed: statusClick,
        );
      case TaskStatusType.snoozed:
        return AkiChip(
          icon: "assets/images/icons/_common/clock.svg",
          backgroundColor: ColorsExt.akiflow10(context),
          text: task.datetimeFormatted,
          onPressed: statusClick,
        );
      case TaskStatusType.planned:
        return AkiChip(
          backgroundColor: ColorsExt.cyan25(context),
          text: task.shortDate,
          onPressed: statusClick,
        );
      default:
        return AkiChip(
          backgroundColor: ColorsExt.cyan25(context),
          text: task.statusType!.name.capitalizeFirstCharacter(),
          onPressed: statusClick,
        );
    }
  }

  Widget _label(BuildContext context) {
    if (task.listId == null || task.listId!.isEmpty) {
      return const SizedBox();
    }

    List<Label> labels = context.watch<TasksCubit>().state.labels;

    if (labels.isEmpty) {
      return const SizedBox();
    }

    Label label = labels.firstWhere(
      (label) => task.listId!.contains(label.id!),
    );

    return AkiChip(
      icon: "assets/images/icons/_common/number.svg",
      text: label.title,
      backgroundColor: label.color != null
          ? ColorsExt.getFromName(label.color!).withOpacity(0.1)
          : null,
      iconColor: label.color != null
          ? ColorsExt.getFromName(label.color!)
          : ColorsExt.grey3(context),
      onPressed: () {
        // TODO label click
      },
    );
  }

  Widget _secondLine(BuildContext context) {
    List<Doc> docs = context.watch<TasksCubit>().state.docs;

    int index = docs.indexWhere(
      (doc) => doc.taskId == task.id,
    );

    if ((task.description == null || task.description!.isEmpty) &&
        index == -1) {
      return const SizedBox();
    }
    return Column(
      children: [
        const SizedBox(height: 4),
        Builder(builder: (context) {
          if (index != -1) {
            return Row(
              children: [
                SvgPicture.asset(
                  docs[index].computedIcon,
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  t.task.linkedContent,
                  style:
                      TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                SvgPicture.asset(
                  "assets/images/icons/_common/arrow_turn_down_right.svg",
                  color: ColorsExt.grey3(context),
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4.5),
                Text(
                  t.task.description,
                  style:
                      TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
                ),
              ],
            );
          }
        }),
      ],
    );
  }
}
