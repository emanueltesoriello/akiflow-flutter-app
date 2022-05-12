import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile/style/theme.dart';

class ButtonComp extends StatefulWidget {
  final Widget child;
  final Function()? onPressed;

  const ButtonComp({
    Key? key,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  @override
  State<ButtonComp> createState() => _ButtonCompState();
}

class _ButtonCompState extends State<ButtonComp> with SingleTickerProviderStateMixin {
  Animation<Color?>? _animation;
  late AnimationController _controller;

  final ValueNotifier<bool> _colorContextReady = ValueNotifier<bool>(false);

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
      vsync: this,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animation = ColorTween(
        begin: Theme.of(context).primaryColorLight,
        end: Theme.of(context).primaryColor,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
      _colorContextReady.value = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onLongPressCancel: () => _controller.reverse(),
      onLongPressEnd: (_) => _controller.reverse(),
      child: ValueListenableBuilder(
        valueListenable: _colorContextReady,
        builder: (context, bool ready, child) {
          if (!ready) {
            return Container();
          }

          return AnimatedBuilder(
            animation: _animation!,
            builder: (_, child) => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: border,
                ),
                color: _animation!.value,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                child: Center(child: widget.child),
              ),
            ),
          );
        },
      ),
    );
  }
}
