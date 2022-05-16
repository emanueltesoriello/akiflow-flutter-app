import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_action.dart';
import 'package:mobile/components/task/slidable_container.dart';
import 'package:mobile/components/task/slidable_motion.dart';
import 'package:mobile/components/task/task_info.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/edit_task_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class TaskRow extends StatelessWidget {
  final Task task;

  final Function() completedClick;
  final Function() swipeActionPlanClick;
  final Function() swipeActionSelectLabelClick;
  final Function() swipeActionSnoozeClick;
  final Function() selectTask;
  final bool hideInboxLabel;
  final bool selectMode;

  const TaskRow({
    Key? key,
    required this.task,
    required this.completedClick,
    required this.swipeActionPlanClick,
    required this.swipeActionSelectLabelClick,
    required this.swipeActionSnoozeClick,
    required this.selectTask,
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
        onTap: () async {
          EditTaskCubit editTaskCubit = EditTaskCubit(context.read<TasksCubit>(), task: task);

          await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => BlocProvider(
              create: (context) => editTaskCubit,
              child: const EditTaskModal(),
            ),
          );

          editTaskCubit.modalDismissed();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
          color: (task.selected ?? false) ? ColorsExt.grey6(context) : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Builder(
                  builder: (context) {
                    Color? color;

                    try {
                      if (task.content["expiredSnooze"] == true) {
                        color = ColorsExt.pink(context);
                      }
                    } catch (_) {}

                    if (task.readAt == null) {
                      color = ColorsExt.cyan(context);
                    }

                    if (color == null) {
                      return const SizedBox();
                    }

                    return Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.all(16 - 10),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 20,
                height: 20,
                child: Builder(builder: (context) {
                  if (selectMode) {
                    return _radio(context);
                  } else {
                    return _checkbox();
                  }
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _firstLine(context),
                    _secondLine(context),
                    TaskInfo(
                      task,
                      hideInboxLabel: hideInboxLabel,
                      selectDate: context.watch<EditTaskCubit>().state.selectedDate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _firstLine(BuildContext context) {
    String? text = task.title;

    if (text == null || text.isEmpty) {
      text = t.task.noTitle;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: task.statusType == TaskStatusType.deleted || task.deletedAt != null
                  ? ColorsExt.grey3(context)
                  : ColorsExt.grey1(context),
            ),
          ),
        ),
        _overdue(context),
      ],
    );
  }

  Widget _overdue(BuildContext context) {
    if (task.isOverdue) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
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
        ),
      );
    }

    return const SizedBox();
  }

  InkWell _checkbox() {
    return InkWell(
      onTap: completedClick,
      child: Builder(builder: (context) {
        bool completed = task.isCompletedComputed;

        Color color;

        switch (task.priority) {
          case 1:
            color = ColorsExt.red(context);
            break;
          case 2:
            color = ColorsExt.yellow(context);
            break;
          case 3:
            color = ColorsExt.green(context);
            break;
          default:
            color = completed ? ColorsExt.grey2(context) : ColorsExt.grey3(context);
        }

        return SvgPicture.asset(
          completed ? "assets/images/icons/_common/Check-done.svg" : "assets/images/icons/_common/Check-empty.svg",
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
        color = ColorsExt.red(context);
        break;
      case 2:
        color = ColorsExt.yellow(context);
        break;
      case 3:
        color = ColorsExt.green(context);
        break;
      default:
        color = ColorsExt.grey3(context);
    }

    return InkWell(
      onTap: selectTask,
      child: SvgPicture.asset(
        selected ? "assets/images/icons/_common/largecircle_fill_circle.svg" : "assets/images/icons/_common/circle.svg",
        width: 20,
        height: 20,
        color: color,
      ),
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
          swipeActionPlanClick();
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
        Flexible(
          child: Builder(builder: (context) {
            return ButtonAction(
              backColor: ColorsExt.grey5(context),
              topColor: ColorsExt.grey3(context),
              icon: 'assets/images/icons/_common/number.svg',
              click: () {
                Slidable.of(context)?.close();
                swipeActionSelectLabelClick();
              },
            );
          }),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Builder(builder: (context) {
            return ButtonAction(
              backColor: ColorsExt.pink30(context),
              topColor: ColorsExt.pink(context),
              icon: 'assets/images/icons/_common/clock.svg',
              click: () {
                Slidable.of(context)?.close();
                swipeActionSnoozeClick();
              },
            );
          }),
        ),
        const SizedBox(width: 16),
        Flexible(child: _planButton(withLabel: withLabel)),
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
          swipeActionPlanClick();
        },
      );
    });
  }

  Widget _secondLine(BuildContext context) {
    List<Doc> docs = context.watch<TasksCubit>().state.docs;

    Doc? doc = docs.firstWhereOrNull(
      (doc) => doc.taskId == task.id,
    );

    if ((task.description == null || task.description!.isEmpty) && doc == null) {
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
                  style: TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
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
                          style: TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
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
