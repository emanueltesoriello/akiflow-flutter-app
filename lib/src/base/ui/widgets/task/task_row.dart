import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/slidable_button_action.dart';
import 'package:mobile/src/base/ui/widgets/task/checkbox_animated.dart';
import 'package:mobile/src/base/ui/widgets/task/components/done_with_label.dart';
import 'package:mobile/src/base/ui/widgets/task/components/subtitle_widget.dart';
import 'package:mobile/src/base/ui/widgets/task/components/title_widget.dart';
import 'package:mobile/src/base/ui/widgets/task/slidable_motion.dart';
import 'package:mobile/src/base/ui/widgets/task/slidable_sender.dart';
import 'package:mobile/src/base/ui/widgets/task/task_info.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:models/task/task.dart';

import 'components/background_daily_goal.dart';
import 'components/dot_prefix.dart';
import 'components/selectable_radio_button.dart';

class TaskRow extends StatefulWidget {
  static const int dailyGoalScaleDurationInMillis = 500;
  static const int dailyGoalBackgroundAppearDelay = 250;
  static const int fadeOutDurationInMillis = 200;

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
  final bool openedFromCalendarGroupedTasks;
  final Color? color;

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
    this.color,
    this.enableLongPressToSelect = false,
    this.isOnboarding = false,
    this.openedFromCalendarGroupedTasks = false,
  }) : super(key: key);

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> with TickerProviderStateMixin {
  CheckboxAnimatedController? _checkboxController;

  late AnimationController _dailyGoalAnimationController = AnimationController(vsync: this);

  late AnimationController _fadeOutAnimationController = AnimationController(vsync: this);
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _dailyGoalAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this, lowerBound: 0, upperBound: 1, value: 0);

    _fadeOutAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this, lowerBound: 0, upperBound: 1, value: 0);
    _fadeOutAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeOutAnimationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fadeOutAnimation = Tween<double>(begin: 0, end: 1).animate(_fadeOutAnimationController);
    });
  }

  @override
  dispose() {
    _dailyGoalAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.isOnboarding ? BorderRadius.circular(Dimension.radius) : BorderRadius.zero,
      child: Slidable(
        key: ValueKey(widget.task.id),
        groupTag: "task",
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.18,
          openThreshold: 0.20,
          dismissible: DismissiblePane(
            resizeDuration: const Duration(milliseconds: 300),
            closeOnCancel: false,
            dismissThreshold: 0.18,
            confirmDismiss: () async {
              await Slidable.of(context)?.close();
              Future.delayed(const Duration(milliseconds: 300), () {
                widget.task.playTaskDoneSound();
                widget.completedClick();
              });
              return true;
            },
            onDismissed: () {},
            motion: SlidableMotion(
              dismissThreshold: 0.18,
              motionChild: Container(
                color: ColorsExt.green20(context),
                child: DoneWithLabel(
                    key: Key(widget.task.id!),
                    click: () async {
                      await Slidable.of(context)?.close();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        widget.task.playTaskDoneSound();
                        widget.completedClick();
                      });
                    },
                    withLabel: false),
              ),
              staticChild: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    color: ColorsExt.grey6(context),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: DoneWithLabel(
                        iconColor: ColorsExt.grey3(context),
                        key: Key(widget.task.id!),
                        click: () async {
                          await Slidable.of(context)?.close();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            widget.task.playTaskDoneSound();
                            widget.completedClick();
                          });
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
              return CustomSlidableAction(
                backgroundColor: ColorsExt.grey6(context),
                foregroundColor: ColorsExt.grey3(context),
                onPressed: (context) {},
                padding: EdgeInsets.zero,
                child: SlidableButtonAction(
                  backColor: ColorsExt.grey6(context),
                  topColor: ColorsExt.grey3(context),
                  icon: Assets.images.icons.common.checkDoneSVG,
                  leftToRight: true,
                  click: () async {
                    await Slidable.of(context)?.close();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      widget.task.playTaskDoneSound();
                      widget.completedClick();
                    });
                  },
                ),
              );
            }),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.6,
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
                  icon: Assets.images.icons.common.numberSVG,
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
                  icon: Assets.images.icons.common.clockSVG,
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
                  icon: Assets.images.icons.common.calendarSVG,
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
              if (widget.openedFromCalendarGroupedTasks) {
                Navigator.pop(context);
              }
              TaskExt.editTask(context, widget.task);
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              color: widget.color ?? ((widget.task.selected ?? false) ? ColorsExt.grey7(context) : Colors.transparent),
              child: Stack(
                children: [
                  BackgroundDailyGoal(
                    task: widget.task,
                    dailyGoalAnimationController: _dailyGoalAnimationController,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: Dimension.padding, top: Dimension.padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!widget.selectMode) {
                              widget.task.playTaskDoneSound();
                              _checkboxController!.completedClick();
                            }
                          },
                          child: SizedBox(
                            width: 50,
                            child: Row(
                              children: [
                                DotPrefix(task: widget.task),
                                Builder(builder: ((context) {
                                  if (widget.selectMode) {
                                    return SizedBox(
                                        width: Dimension.appBarLeadingIcon,
                                        height: Dimension.appBarLeadingIcon,
                                        child: Center(child: SelectableRadioButton(widget.task)));
                                  } else {
                                    return CheckboxAnimated(
                                      onControllerReady: (controller) {
                                        _checkboxController = controller;
                                      },
                                      task: widget.task,
                                      key: ObjectKey(widget.task.id),
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
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            child: IgnorePointer(
                                ignoring: _fadeOutAnimation.value == 0 ? false : true,
                                child: AnimatedBuilder(
                                    animation: _fadeOutAnimation,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _fadeOutAnimation.value == 0 ? 1.0 : 0.0,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TitleWidget(widget.task),
                                            const SizedBox(height: Dimension.paddingXS),
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
                                      );
                                    }))),
                      ],
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
