import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/common/components/task/checkbox_animated.dart';
import 'package:mobile/common/components/task/components/done_with_label.dart';
import 'package:mobile/common/components/task/components/plan_with_label.dart';
import 'package:mobile/common/components/task/components/title_widget.dart';
import 'package:mobile/common/components/task/slidable_motion.dart';
import 'package:mobile/common/components/task/slidable_sender.dart';
import 'package:mobile/common/components/task/task_info.dart';
import 'package:mobile/features/tasks/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/slidable_button_action.dart';
import 'package:models/task/task.dart';

import 'components/background_daily_goal.dart';
import 'components/dot_prefix.dart';
import 'components/selectable_radio_button.dart';
import 'components/subtitle_widget.dart';

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
  final bool isOnboarding;

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
    this.isOnboarding = false,
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
        duration: const Duration(milliseconds: 100), vsync: this, lowerBound: 0, upperBound: 1, value: 0);

    _fadeOutAnimationController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this, lowerBound: 0, upperBound: 1, value: 0);
    _fadeOutAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeOutAnimationController);
  }

  @override
  dispose() {
    _dailyGoalAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.isOnboarding ? BorderRadius.circular(8) : BorderRadius.zero,
      child: Slidable(
        key: ValueKey(widget.task.id),
        groupTag: "task",
        startActionPane: ActionPane(
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
                      child: DoneWithLabel(
                          click: () {
                            Slidable.of(context)?.close();
                            widget.completedClick();
                          },
                          withLabel: true),
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
                    child: DoneWithLabel(
                        click: () {
                          Slidable.of(context)?.close();
                          widget.completedClick();
                        },
                        withLabel: false),
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
        ),
        endActionPane: ActionPane(
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
                      child: PlanWithLabel(
                        click: () {
                          Slidable.of(context)?.close();
                          widget.swipeActionPlanClick();
                        },
                      ),
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
                    child: PlanWithLabel(
                      click: () {
                        Slidable.of(context)?.close();
                        widget.swipeActionPlanClick();
                      },
                    ),
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
        ),
        child: Builder(builder: (context) {
          Widget child = GestureDetector(
            onLongPress: widget.enableLongPressToSelect ? () => widget.selectTask() : null,
            onTap: () async {
              TaskExt.editTask(context, widget.task);
            },
            child: SizedBox(
              child: Stack(
                children: [
                  BackgroundDailyGoal(
                    task: widget.task,
                    dailyGoalAnimationController: _dailyGoalAnimationController,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Material(
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
                            child: SizedBox(
                              width: 48,
                              height: (widget.task.title?.length ?? 0) > 40 ? 80 : 40,
                              child: Row(
                                children: [
                                  DotPrefix(task: widget.task),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Builder(builder: ((context) {
                                      if (widget.selectMode) {
                                        return SelectableRadioButton(widget.task);
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
                                  TitleWidget(widget.task),
                                  Subtitle(widget.task),
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
                  ),
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _fadeOutAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeOutAnimation.value,
                          child: Container(
                              constraints: BoxConstraints(
                                minHeight: (widget.task.title?.length ?? 0) > 40 ? 80 : 40,
                              ),
                              color: Theme.of(context).scaffoldBackgroundColor),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );

          if (widget.isOnboarding) {
            return SlidableControllerSender(child: child);
          } else {
            return child;
          }
        }),
      ),
    );
  }
}
