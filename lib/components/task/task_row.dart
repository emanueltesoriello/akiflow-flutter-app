import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/aki_chip.dart';
import 'package:mobile/components/base/button_action.dart';
import 'package:mobile/components/task/slidable_container.dart';
import 'package:mobile/components/task/slidable_motion.dart';
import 'package:mobile/features/edit_task/ui/edit_task_modal.dart';
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
  final bool selectMode;

  const TaskRow({
    Key? key,
    required this.task,
    required this.completedClick,
    required this.planClick,
    required this.selectLabelClick,
    required this.snoozeClick,
    this.hideInboxLabel = false,
    this.selectMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      groupTag: "task",
      startActionPane: _startActions(context),
      endActionPane: _endActions(context),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => EditTaskModal(task: task),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.all(16),
          color: (task.selected ?? false)
              ? ColorsExt.grey6(context)
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(builder: (context) {
                if (selectMode) {
                  return _radio(context);
                } else {
                  return _checkbox();
                }
              }),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _firstLine(context),
                    _secondLine(context),
                    _thirdLine(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thirdLine(BuildContext context) {
    return Column(
      children: [
        Builder(builder: (context) {
          if (task.statusType == null &&
              !task.isOverdue &&
              task.listId == null &&
              !hideInboxLabel) {
            return const SizedBox();
          }

          return const SizedBox(height: 10.5);
        }),
        Wrap(
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
        ),
      ],
    );
  }

  Text _firstLine(BuildContext context) {
    String? text = task.title;

    if (text == null || text.isEmpty) {
      text = t.task.noTitle;
    }

    return Text(
      text,
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

  InkWell _checkbox() {
    return InkWell(
      onTap: completedClick,
      child: Builder(builder: (context) {
        bool completed = task.isCompletedComputed;

        Color color;

        switch (task.priority) {
          case 1:
            color = ColorsExt.green(context);
            break;
          case 2:
            color = ColorsExt.yellow(context);
            break;
          case 3:
            color = ColorsExt.red(context);
            break;
          default:
            color =
                completed ? ColorsExt.grey2(context) : ColorsExt.grey3(context);
        }

        return SvgPicture.asset(
          completed
              ? "assets/images/icons/_common/Check-done.svg"
              : "assets/images/icons/_common/Check-empty.svg",
          width: 20,
          height: 20,
          color: color,
        );
      }),
    );
  }

  Widget _radio(BuildContext context) {
    bool selected = task.selected ?? false;

    Color color;

    switch (task.priority) {
      case 1:
        color = ColorsExt.green(context);
        break;
      case 2:
        color = ColorsExt.yellow(context);
        break;
      case 3:
        color = ColorsExt.red(context);
        break;
      default:
        color = ColorsExt.grey3(context);
    }

    return SvgPicture.asset(
      selected
          ? "assets/images/icons/_common/largecircle_fill_circle.svg"
          : "assets/images/icons/_common/circle.svg",
      width: 20,
      height: 20,
      color: color,
    );
  }

  ActionPane _startActions(BuildContext context) {
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: 0.2,
      dismissible: DismissiblePane(
        closeOnCancel: true,
        dismissThreshold: 0.5,
        confirmDismiss: () async {
          completedClick();
          return false;
        },
        onDismissed: () {},
        motion: SlidableContainer(
          child: SlidableMotion(
            dismissThreshold: 0.5,
            motionChild: _doneButton(withLabel: true),
            staticChild: _doneButton(),
            leftToRight: true,
          ),
        ),
      ),
      children: [
        Flexible(child: SlidableContainer(child: _doneButton())),
      ],
    );
  }

  Widget _doneButton({bool withLabel = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 16),
        Builder(builder: (context) {
          return ButtonAction(
            backColor: ColorsExt.green20(context),
            topColor: ColorsExt.green(context),
            icon: 'assets/images/icons/_common/Check-done.svg',
            label: withLabel ? t.task.done.toUpperCase() : null,
            click: () {
              Slidable.of(context)?.close();
              completedClick();
            },
          );
        }),
      ],
    );
  }

  ActionPane _endActions(BuildContext context) {
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: 0.5,
      dismissible: DismissiblePane(
        closeOnCancel: true,
        dismissThreshold: 0.75,
        confirmDismiss: () async {
          planClick();
          return false;
        },
        onDismissed: () {},
        motion: SlidableContainer(
          child: SlidableMotion(
            dismissThreshold: 0.75,
            motionChild: _endActionsPane(withLabel: true),
            staticChild: _endActionsPane(),
            leftToRight: false,
          ),
        ),
      ),
      children: [
        Flexible(child: SlidableContainer(child: _endActionsPane())),
      ],
    );
  }

  Widget _endActionsPane({bool withLabel = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 16),
        Builder(builder: (context) {
          return ButtonAction(
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
          return ButtonAction(
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
        _planButton(withLabel: withLabel),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _planButton({bool withLabel = false}) {
    return Builder(builder: (context) {
      return ButtonAction(
        backColor: ColorsExt.cyan25(context),
        topColor: ColorsExt.cyan(context),
        icon: 'assets/images/icons/_common/calendar.svg',
        label: withLabel ? t.task.plan.toUpperCase() : null,
        click: () {
          Slidable.of(context)?.close();
          planClick();
        },
      );
    });
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

    if (task.isOverdue) {
      return AkiChip(
        backgroundColor: ColorsExt.cyan25(context),
        text: task.overdueFormatted,
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

    Label? label = labels.firstWhereOrNull(
      (label) => task.listId!.contains(label.id!),
    );

    if (label == null) {
      return const SizedBox();
    }

    return AkiChip(
      icon: "assets/images/icons/_common/number.svg",
      text: label.title,
      backgroundColor: label.color != null
          ? ColorsExt.getFromName(label.color!).withOpacity(0.1)
          : null,
      iconColor: label.color != null
          ? ColorsExt.getFromName(label.color!)
          : ColorsExt.grey3(context),
      onPressed: () {},
    );
  }

  Widget _secondLine(BuildContext context) {
    List<Doc> docs = context.watch<TasksCubit>().state.docs;

    Doc? doc = docs.firstWhereOrNull(
      (doc) => doc.taskId == task.id,
    );

    if ((task.description == null || task.description!.isEmpty) &&
        doc == null) {
      return const SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        Builder(builder: (context) {
          if (doc != null) {
            return Row(
              children: [
                SvgPicture.asset(
                  doc.computedIcon,
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
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.description ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15, color: ColorsExt.grey3(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }),
      ],
    );
  }
}
