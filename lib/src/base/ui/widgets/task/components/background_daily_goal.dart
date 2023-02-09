import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:models/task/task.dart';

class BackgroundDailyGoal extends StatefulWidget {
  const BackgroundDailyGoal({
    Key? key,
    required Task task,
    required AnimationController dailyGoalAnimationController,
  })  : _dailyGoalAnimationController = dailyGoalAnimationController,
        _task = task,
        super(key: key);

  final Task _task;
  final AnimationController _dailyGoalAnimationController;

  @override
  State<BackgroundDailyGoal> createState() => _BackgroundDailyGoalState();
}

class _BackgroundDailyGoalState extends State<BackgroundDailyGoal> {
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
            constraints: BoxConstraints(
              minHeight: (widget._task.title?.length ?? 0) > 40 ? 80 : 40,
            ),
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
