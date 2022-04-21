import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableMotion extends StatefulWidget {
  final double dismissThreshold;
  final Widget motionChild;
  final Widget staticChild;

  const SlidableMotion({
    Key? key,
    required this.dismissThreshold,
    required this.motionChild,
    required this.staticChild,
  }) : super(key: key);

  @override
  _SlidableMotionState createState() => _SlidableMotionState();
}

class _SlidableMotionState extends State<SlidableMotion> {
  final ValueNotifier<double> animationRationNotifier =
      ValueNotifier<double>(0);

  @override
  Widget build(BuildContext context) {
    SlidableController? controller = Slidable.of(context);

    controller?.animation.addListener(() {
      animationRationNotifier.value = controller.ratio;
    });

    return ValueListenableBuilder(
        valueListenable: animationRationNotifier,
        builder: (context, double value, child) {
          if (value < widget.dismissThreshold) {
            // controller?.close();
            return widget.staticChild;
          } else {
            return widget.motionChild;
          }
        });
  }
}
