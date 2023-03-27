import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile/common/style/sizes.dart';

class ActionButton extends StatefulWidget {
  final Widget child;
  final Function()? onPressed;
  final Color? color;
  final Color? splashColor;
  final Color? borderColor;

  const ActionButton({Key? key, required this.child, this.onPressed, this.color, this.splashColor, this.borderColor})
      : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> with SingleTickerProviderStateMixin {
  Animation<Color?>? _animation;
  late AnimationController _controller;

  final ValueNotifier<bool> _colorContextReady = ValueNotifier<bool>(false);

  @override
  void initState() {
    initWidget();
    super.initState();
  }

  initWidget() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
      vsync: this,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animation = ((widget.color != null && widget.splashColor != null)
              ? ColorTween(
                  begin: widget.color,
                  end: widget.splashColor,
                )
              : ColorTween(
                  begin: Theme.of(context).primaryColorLight,
                  end: Theme.of(context).primaryColor,
                ))
          .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
      _colorContextReady.value = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.key,
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
            return const SizedBox();
          }

          return AnimatedBuilder(
            animation: _animation!,
            builder: (_, child) => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimension.radius),
                border: Border.all(
                  color: widget.borderColor ?? Theme.of(context).primaryColor,
                  width: Dimension.border,
                ),
                color: _animation!.value,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS, vertical: Dimension.paddingSM),
                child: Center(child: widget.child),
              ),
            ),
          );
        },
      ),
    );
  }
}
