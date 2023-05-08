import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

class AnimatedChevron extends StatefulWidget {
  final bool iconUp;
  final Function()? onPressed;
  const AnimatedChevron({Key? key, required this.iconUp, this.onPressed}) : super(key: key);

  @override
  State<AnimatedChevron> createState() => _AnimatedChevronState();
}

class _AnimatedChevronState extends State<AnimatedChevron> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
    );
    super.initState();
  }

  void revert() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedChevron oldWidget) {
    print("didUpdateWidget");
    super.didUpdateWidget(oldWidget);
    if (widget.iconUp != oldWidget.iconUp) {
      revert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: RotationTransition(
        turns: Tween(begin: 1.0, end: 0.0).animate(_controller),
        child: SvgPicture.asset(
          Assets.images.icons.common.chevronDownSVG,
          width: Dimension.chevronIconSize,
          height: Dimension.chevronIconSize,
          color: ColorsExt.grey600(context),
        ),
      ),
    );
  }
}
