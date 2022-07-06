import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/slidable_button_action.dart';
import 'package:mobile/components/task/checkbox_animated.dart';
import 'package:mobile/components/task/slidable_motion.dart';
import 'package:mobile/components/task/task_info.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class TaskRow extends StatefulWidget {
  static const int dailyGoalScaleDurationInMillis = 500;
  static const int dailyGoalBackgroundAppearDelay = 250;
  static const int fadeOutDurationInMillis = 500;

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
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> with TickerProviderStateMixin {
  CheckboxAnimatedController? _checkboxController;

  late AnimationController _dailyGoalAnimationController;

  late AnimationController _fadeOutAnimationController;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _dailyGoalAnimationController = AnimationController(
        duration: const Duration(milliseconds: TaskRow.dailyGoalScaleDurationInMillis),
        vsync: this,
        lowerBound: 0,
        upperBound: 1,
        value: 0);

    _fadeOutAnimationController = AnimationController(
        duration: const Duration(milliseconds: TaskRow.fadeOutDurationInMillis),
        vsync: this,
        lowerBound: 0,
        upperBound: 1,
        value: 0);
    _fadeOutAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeOutAnimationController);
  }

  @override
  dispose() {
    _dailyGoalAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.task.id),
      groupTag: "task",
      startActionPane: _startActions(context),
      endActionPane: _endActions(context),
      child: GestureDetector(
        onLongPress: widget.enableLongPressToSelect ? () => widget.selectTask() : null,
        onTap: () async {
          TaskExt.editTask(context, widget.task);
        },
        child: IntrinsicHeight(
          child: Stack(
            children: [
              _BackgroundDailyGoal(
                task: widget.task,
                dailyGoalAnimationController: _dailyGoalAnimationController,
              ),
              Container(
                constraints: const BoxConstraints(minHeight: 50),
                padding: const EdgeInsets.only(right: 14),
                color: (widget.task.selected ?? false) ? ColorsExt.grey6(context) : Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.selectMode) {
                          widget.selectTask();
                        } else {
                          _checkboxController!.completedClick();
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: 48,
                        child: Row(
                          children: [
                            _DotPrefix(widget.task),
                            Container(
                              padding: const EdgeInsets.only(top: 12),
                              child: Builder(builder: ((context) {
                                if (widget.selectMode) {
                                  return _SelectableRadioButton(widget.task);
                                } else {
                                  return CheckboxAnimated(
                                    onControllerReady: (controller) {
                                      _checkboxController = controller;
                                    },
                                    task: widget.task,
                                    key: ObjectKey(widget.task),
                                    onCompleted: () async {
                                      if (widget.task.isDailyGoal) {
                                        _dailyGoalAnimationController.value = 1;
                                        await Future.delayed(
                                            const Duration(milliseconds: TaskRow.dailyGoalBackgroundAppearDelay));
                                        _dailyGoalAnimationController.reverse(from: 1);
                                        await Future.delayed(
                                            const Duration(milliseconds: TaskRow.dailyGoalScaleDurationInMillis));
                                      }

                                      _fadeOutAnimationController.forward(from: 0);
                                      await Future.delayed(
                                          const Duration(milliseconds: TaskRow.fadeOutDurationInMillis));
                                      widget.completedClick();
                                    },
                                  );
                                }
                              })),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Title(widget.task),
                            _Subtitle(widget.task),
                            TaskInfo(
                              widget.task,
                              hideInboxLabel: widget.hideInboxLabel,
                              showLabel: widget.showLabel,
                              selectDate: context.watch<EditTaskCubit>().state.selectedDate,
                              showPlanInfo: widget.showPlanInfo,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _fadeOutAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeOutAnimation.value,
                      child: Container(
                          constraints: const BoxConstraints(minHeight: 50),
                          color: Theme.of(context).scaffoldBackgroundColor),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ActionPane _startActions(BuildContext context) {
    return ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.2,
      dismissible: DismissiblePane(
        closeOnCancel: true,
        dismissThreshold: 0.25,
        confirmDismiss: () async {
          widget.completedClick();
          return false;
        },
        onDismissed: () {},
        motion: SlidableMotion(
          dismissThreshold: 0.25,
          motionChild: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: ColorsExt.green20(context),
                  padding: const EdgeInsets.symmetric(horizontal: 27),
                  child: _doneWithLabel(context),
                ),
              ),
            ],
          ),
          staticChild: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: ColorsExt.green20(context),
                width: MediaQuery.of(context).size.width * 0.2,
                child: _doneWithLabel(context, withLabel: false),
              ),
            ],
          ),
          leftToRight: true,
        ),
      ),
      children: [
        Builder(builder: (context) {
          // builder is used to get the context of the slidable, not remove!
          return CustomSlidableAction(
            backgroundColor: ColorsExt.green20(context),
            foregroundColor: ColorsExt.green(context),
            onPressed: (context) {},
            padding: EdgeInsets.zero,
            child: SlidableButtonAction(
              backColor: ColorsExt.green20(context),
              topColor: ColorsExt.green(context),
              icon: 'assets/images/icons/_common/Check-done.svg',
              leftToRight: true,
              click: () {
                Slidable.of(context)?.close();
                widget.swipeActionSelectLabelClick();
              },
            ),
          );
        }),
      ],
    );
  }

  Row _doneWithLabel(BuildContext context, {bool withLabel = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: SlidableButtonAction(
            backColor: ColorsExt.green20(context),
            topColor: ColorsExt.green(context),
            icon: 'assets/images/icons/_common/Check-done.svg',
            label: withLabel ? t.task.done.toUpperCase() : null,
            leftToRight: true,
            click: () {
              Slidable.of(context)?.close();
              widget.completedClick();
            },
          ),
        ),
      ],
    );
  }

  ActionPane _endActions(BuildContext context) {
    return ActionPane(
      motion: const DrawerMotion(),
      extentRatio: 0.6,
      dismissible: DismissiblePane(
        closeOnCancel: true,
        dismissThreshold: 0.75,
        confirmDismiss: () async {
          widget.swipeActionPlanClick();
          return false;
        },
        onDismissed: () {},
        motion: SlidableMotion(
          dismissThreshold: 0.75,
          motionChild: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  color: ColorsExt.cyan25(context),
                  padding: const EdgeInsets.symmetric(horizontal: 27),
                  child: _planWithLabel(context),
                ),
              ),
            ],
          ),
          staticChild: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                color: ColorsExt.cyan25(context),
                width: MediaQuery.of(context).size.width * 0.6,
                padding: const EdgeInsets.symmetric(horizontal: 27),
                child: _planWithLabel(context),
              ),
            ],
          ),
          leftToRight: false,
        ),
      ),
      children: [
        Builder(builder: (context) {
          // builder is used to get the context of the slidable, not remove!
          return CustomSlidableAction(
            backgroundColor: ColorsExt.grey5(context),
            foregroundColor: ColorsExt.grey3(context),
            onPressed: (context) {},
            padding: EdgeInsets.zero,
            child: SlidableButtonAction(
              backColor: ColorsExt.grey5(context),
              topColor: ColorsExt.grey3(context),
              icon: 'assets/images/icons/_common/number.svg',
              leftToRight: false,
              click: () {
                Slidable.of(context)?.close();
                widget.swipeActionSelectLabelClick();
              },
            ),
          );
        }),
        Builder(builder: (context) {
          // builder is used to get the context of the slidable, not remove!
          return CustomSlidableAction(
            backgroundColor: ColorsExt.pink30(context),
            foregroundColor: ColorsExt.pink(context),
            onPressed: (context) {},
            padding: EdgeInsets.zero,
            child: SlidableButtonAction(
              backColor: ColorsExt.pink30(context),
              topColor: ColorsExt.pink(context),
              icon: 'assets/images/icons/_common/clock.svg',
              leftToRight: false,
              click: () {
                Slidable.of(context)?.close();
                widget.swipeActionSnoozeClick();
              },
            ),
          );
        }),
        Builder(builder: (context) {
          // builder is used to get the context of the slidable, not remove!
          return CustomSlidableAction(
            backgroundColor: ColorsExt.cyan25(context),
            foregroundColor: ColorsExt.cyan(context),
            onPressed: (context) {},
            padding: EdgeInsets.zero,
            child: SlidableButtonAction(
              backColor: ColorsExt.cyan25(context),
              topColor: ColorsExt.cyan(context),
              icon: 'assets/images/icons/_common/calendar.svg',
              leftToRight: false,
              click: () {
                Slidable.of(context)?.close();
                widget.swipeActionPlanClick();
              },
            ),
          );
        }),
      ],
    );
  }

  Row _planWithLabel(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: SlidableButtonAction(
            backColor: ColorsExt.cyan25(context),
            topColor: ColorsExt.cyan(context),
            icon: 'assets/images/icons/_common/calendar.svg',
            label: t.task.plan.toUpperCase(),
            leftToRight: false,
            click: () {
              Slidable.of(context)?.close();
              widget.swipeActionPlanClick();
            },
          ),
        ),
      ],
    );
  }
}

class _BackgroundDailyGoal extends StatefulWidget {
  const _BackgroundDailyGoal({
    Key? key,
    required Task task,
    required AnimationController dailyGoalAnimationController,
  })  : _dailyGoalAnimationController = dailyGoalAnimationController,
        _task = task,
        super(key: key);

  final Task _task;
  final AnimationController _dailyGoalAnimationController;

  @override
  State<_BackgroundDailyGoal> createState() => _BackgroundDailyGoalState();
}

class _BackgroundDailyGoalState extends State<_BackgroundDailyGoal> {
  late Animation<double> _dailyGoalAnimataion;

  @override
  void initState() {
    _dailyGoalAnimataion = CurvedAnimation(
      parent: widget._dailyGoalAnimationController,
      curve: Curves.easeIn,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget._dailyGoalAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scaleX: _dailyGoalAnimataion.value,
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: () {
                if (widget._task.isDailyGoal) {
                  return Colors.white;
                } else {
                  return (widget._task.selected ?? false) ? ColorsExt.grey6(context) : Colors.transparent;
                }
              }(),
              gradient: () {
                if (!widget._task.isDailyGoal) {
                  return null;
                }

                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xffAF38F9).withOpacity(0.15),
                    const Color(0xffFB8822).withOpacity(0.15),
                    const Color(0xffFFA4A7).withOpacity(0.15),
                  ],
                );
              }(),
            ),
          ),
        );
      },
    );
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

  const _SelectableRadioButton(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool selected = task.selected ?? false;

    Color color = selected ? ColorsExt.akiflow(context) : ColorsExt.grey3(context);

    return Container(
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
      child: Container(
        constraints: const BoxConstraints(minHeight: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1.3,
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
                  const SizedBox(width: 6),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        return Text(
                          doc?.getSummary ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: ColorsExt.grey3(context),
                            height: 1,
                          ),
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
                      height: 1,
                      fontSize: 15,
                      color: ColorsExt.grey3(context),
                    ),
                  )),
                ],
              );
            } else if (links.isNotEmpty) {
              String text;

              if (links.length > 1) {
                text = "${links.length} ${t.task.links.links}";
              } else {
                text = links.first;
              }

              String? iconAsset = TaskExt.iconAssetFromUrl(links.first);
              String? networkIcon = TaskExt.iconNetworkFromUrl(links.first);

              return Row(children: [
                SvgPicture.asset(
                  "assets/images/icons/_common/arrow_turn_down_right.svg",
                  color: ColorsExt.grey3(context),
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 4.5),
                Expanded(
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
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            height: 1,
                            fontSize: 15,
                            color: ColorsExt.grey3(context),
                          ),
                        ),
                      )
                    ],
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
