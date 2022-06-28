import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_action.dart';
import 'package:mobile/components/task/checkbox_animated.dart';
import 'package:mobile/components/task/slidable_container.dart';
import 'package:mobile/components/task/slidable_motion.dart';
import 'package:mobile/components/task/task_info.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskRow extends StatelessWidget {
  final Task task;

  final Function() completedClick;
  final Function() swipeActionPlanClick;
  final Function() swipeActionSelectLabelClick;
  final Function() swipeActionSnoozeClick;
  final Function() selectTask;
  final bool hideInboxLabel;
  final bool selectMode;
  final bool showLabel;
  final bool showPlanInfo;
  final bool enableLongPressToSelect;

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
    required this.showLabel,
    required this.showPlanInfo,
    this.enableLongPressToSelect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      groupTag: "task",
      startActionPane: _startActions(context),
      endActionPane: _endActions(context),
      child: GestureDetector(
        onLongPress: enableLongPressToSelect ? () => selectTask() : null,
        onTap: () async {
          TaskExt.editTask(context, task);
        },
        child: IntrinsicHeight(
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.only(bottom: 12, right: 14),
            color: (task.selected ?? false) ? ColorsExt.grey6(context) : Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DotPrefix(task),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Builder(builder: ((context) {
                    if (selectMode) {
                      return _SelectableRadioButton(task, selectTask: selectTask);
                    } else {
                      return CheckboxAnimated(
                        task,
                        key: ObjectKey(task),
                        onTap: () {
                          completedClick();
                        },
                      );
                    }
                  })),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Title(task),
                        _Subtitle(task),
                        TaskInfo(
                          task,
                          hideInboxLabel: hideInboxLabel,
                          showLabel: showLabel,
                          selectDate: context.watch<EditTaskCubit>().state.selectedDate,
                          showPlanInfo: showPlanInfo,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
}

class _DotPrefix extends StatelessWidget {
  final Task task;

  const _DotPrefix(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      child: Builder(
        builder: (context) {
          Color? color;

          if (task.statusType == TaskStatusType.inbox && task.readAt == null) {
            color = ColorsExt.cyan(context);
          }

          try {
            if (task.content["expiredSnooze"] == true) {
              color = ColorsExt.pink(context);
            }
          } catch (_) {}

          if (color == null) {
            return const SizedBox();
          }

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 5, right: 0, top: 22),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectableRadioButton extends StatelessWidget {
  final Task task;
  final Function() selectTask;

  const _SelectableRadioButton(this.task, {Key? key, required this.selectTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool selected = task.selected ?? false;

    Color color = selected ? ColorsExt.akiflow(context) : ColorsExt.grey3(context);

    return InkWell(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      onTap: selectTask,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(2.17),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 21.67,
            height: 21.67,
            child: SvgPicture.asset(
              selected
                  ? "assets/images/icons/_common/largecircle_fill_circle_2.svg"
                  : "assets/images/icons/_common/circle.svg",
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final Task task;

  const _Title(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? text = task.title;

    if (text == null || text.isEmpty) {
      text = t.noTitle;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SizedBox(
        height: 22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1,
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
        ),
      ),
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
}

class _Subtitle extends StatelessWidget {
  final Task task;

  const _Subtitle(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Doc> docs = context.watch<TasksCubit>().state.docs;

    Doc? doc = docs.firstWhereOrNull(
      (doc) => doc.taskId == task.id,
    );

    doc = task.computedDoc(doc);

    List<String> links = task.links ?? [];

    if (doc == null && task.descriptionParsed.isEmpty && links.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Builder(builder: (context) {
            if (doc != null) {
              return Row(
                children: [
                  SvgPicture.asset(task.computedIcon(doc), width: 16, height: 16),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        return Text(
                          doc?.getSummary ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, color: ColorsExt.grey3(context)),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (task.descriptionParsed.isNotEmpty) {
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
                      child: Text(
                    task.descriptionParsed,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                      color: ColorsExt.grey3(context),
                    ),
                  )),
                ],
              );
            } else if (links.isNotEmpty) {
              String link = links.first;

              String? iconAsset = TaskExt.iconAssetFromUrl(link);
              String? networkIcon = TaskExt.iconNetworkFromUrl(link);

              return Row(children: [
                SvgPicture.asset(
                  "assets/images/icons/_common/arrow_turn_down_right.svg",
                  color: ColorsExt.grey3(context),
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4.5),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(builder: (context) {
                          if (iconAsset != null) {
                            return SvgPicture.asset(
                              iconAsset,
                              width: 16,
                              height: 16,
                            );
                          } else if (networkIcon != null) {
                            return SizedBox(
                              width: 16,
                              height: 16,
                              child: Center(
                                child: Image.network(
                                  networkIcon,
                                  width: 16,
                                  height: 16,
                                  errorBuilder: (context, error, stacktrace) => Image.asset(
                                    "assets/images/icons/web/faviconV2.png",
                                    width: 16,
                                    height: 16,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        }),
                        const SizedBox(width: 9),
                        Flexible(
                          child: Text(
                            link,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              color: ColorsExt.grey3(context),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]);
            } else {
              return const SizedBox();
            }
          }),
        ],
      ),
    );
  }
}
