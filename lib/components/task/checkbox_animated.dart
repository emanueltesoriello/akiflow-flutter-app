import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class CheckboxAnimated extends StatefulWidget {
  final Task task;
  final Function() onTap;

  const CheckboxAnimated(this.task, {Key? key, required this.onTap}) : super(key: key);

  @override
  State<CheckboxAnimated> createState() => _CheckboxAnimatedState();
}

class _CheckboxAnimatedState extends State<CheckboxAnimated> with TickerProviderStateMixin {
  // ROTATION
  late final AnimationController _controllerRotation;
  late final Animation<double> _animationRotation;

  // SCALE
  late final AnimationController _controllerCircleScale;
  late final Animation<double> _animationCircleScale;

  // BACK OPACITY
  late final AnimationController _controllerBackgroundOpacity;
  late final Animation<double> _animationBackgroundOpacity;

  // FOREGROUND COLOR
  late final AnimationController _controllerForegroundColor;
  late final Animation<Color> _animationForegroundColor;

  // TOP OPACITY
  late final AnimationController _controllerTopOpacity;
  late final Animation<double> _animationTopOpacity;

  // TOP SCALE
  late final AnimationController _controllerTopScale;
  late final Animation<double> _animationTopScale;

  CrossFadeState _crossFadeState = CrossFadeState.showFirst;

  static const int stepDuration = 200;

  @override
  void initState() {
    super.initState();

    // ROTATION
    _controllerRotation = AnimationController(
      duration: const Duration(milliseconds: stepDuration * 4),
      vsync: this,
    );
    _animationRotation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 15), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 15, end: 30), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 30, end: -15), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -15, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controllerRotation, curve: Curves.easeIn));

    // SCALE
    _controllerCircleScale = AnimationController(
      duration: const Duration(milliseconds: stepDuration * 4),
      vsync: this,
    );
    _animationCircleScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1.39), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.39, end: 1.72), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.72, end: 1.9), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.9, end: 1.39), weight: 1),
    ]).animate(CurvedAnimation(parent: _controllerCircleScale, curve: Curves.easeIn));

    // BACK OPACITY
    _controllerBackgroundOpacity = AnimationController(
      duration: const Duration(milliseconds: stepDuration * 4),
      vsync: this,
    );
    _animationBackgroundOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controllerBackgroundOpacity, curve: Curves.easeIn));

    // FOREGROUND COLOR
    _controllerForegroundColor = AnimationController(
      duration: const Duration(milliseconds: stepDuration * 2),
      vsync: this,
    )..addListener(() {
        if (_controllerForegroundColor.isCompleted) {
          _crossFadeState = CrossFadeState.showSecond;
        } else {
          _crossFadeState = CrossFadeState.showFirst;
        }
      });
    _animationForegroundColor = TweenSequence([
      TweenSequenceItem(tween: Tween<Color>(begin: ColorsLight.grey3, end: ColorsLight.grey2), weight: 1),
      TweenSequenceItem(tween: Tween<Color>(begin: ColorsLight.grey2, end: ColorsLight.grey3), weight: 1),
    ]).animate(CurvedAnimation(parent: _controllerForegroundColor, curve: Curves.easeIn));

    // FOREGROUND OPACITY
    _controllerTopOpacity = AnimationController(
      duration: const Duration(milliseconds: stepDuration * 4),
      vsync: this,
    );
    _animationTopOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 1), weight: 1),
    ]).animate(CurvedAnimation(parent: _controllerTopOpacity, curve: Curves.easeIn));

    // TOP SCALE
    _controllerTopScale = AnimationController(
      duration: const Duration(milliseconds: stepDuration * 4),
      vsync: this,
    );
    _animationTopScale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.64), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.64, end: 1), weight: 1),
    ]).animate(CurvedAnimation(parent: _controllerTopScale, curve: Curves.easeIn));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Future.delayed(const Duration(milliseconds: stepDuration * 4 + 400), () {
            widget.onTap();
          });

          _controllerCircleScale.reset();
          _controllerRotation.reset();
          _controllerBackgroundOpacity.reset();
          _controllerForegroundColor.reset();
          _controllerTopOpacity.reset();
          _controllerTopScale.reset();

          _controllerRotation.forward();
          _controllerCircleScale.forward();
          _controllerBackgroundOpacity.forward();
          _controllerForegroundColor.forward();
          _controllerTopOpacity.forward();
          _controllerTopScale.forward();
        },
        child: SizedBox(
          height: double.infinity,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: AnimatedBuilder(
                      animation: _animationCircleScale,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.scale(
                          scale: _animationCircleScale.value,
                          child: AnimatedBuilder(
                            animation: _controllerBackgroundOpacity,
                            builder: (BuildContext context, Widget? child) => Container(
                              decoration: BoxDecoration(
                                color: ColorsExt.grey5(context).withOpacity(_animationBackgroundOpacity.value),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _animationRotation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animationRotation.value * pi / 180,
                            child: AnimatedBuilder(
                              animation: _animationTopScale,
                              builder: (context, child) =>
                                  Transform.scale(scale: _animationTopScale.value, child: checkmark()),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget checkmark() {
    bool completed = widget.task.isCompletedComputed;

    Color color;

    switch (widget.task.priority) {
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
        color = completed ? ColorsExt.grey3(context) : ColorsExt.grey3(context);
    }

    return AnimatedBuilder(
      animation: _animationForegroundColor,
      builder: (BuildContext context, Widget? child) {
        return AnimatedBuilder(
          animation: _animationTopOpacity,
          builder: (BuildContext context, Widget? child) => AnimatedCrossFade(
            firstChild: SvgPicture.asset(
              widget.task.isCompletedComputed
                  ? "assets/images/icons/_common/Check-done.svg"
                  : "assets/images/icons/_common/Check-empty.svg",
              color: color.withOpacity(_animationTopOpacity.value),
            ),
            secondChild: SvgPicture.asset(
              !widget.task.isCompletedComputed
                  ? "assets/images/icons/_common/Check-done.svg"
                  : "assets/images/icons/_common/Check-empty.svg",
              color: !widget.task.isCompletedComputed
                  ? ColorsExt.green(context).withOpacity(_animationTopOpacity.value)
                  : color.withOpacity(_animationTopOpacity.value),
            ),
            crossFadeState: _crossFadeState,
            duration: const Duration(milliseconds: 200),
          ),
        );
      },
    );
  }
}
