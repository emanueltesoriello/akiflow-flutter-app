import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/leading_icon.dart';

class ButtonSelectable extends StatefulWidget {
  final String title;
  final Function() onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final Color? titleColor;

  const ButtonSelectable({
    Key? key,
    required this.title,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.selected = false,
    this.titleColor,
  }) : super(key: key);

  @override
  State<ButtonSelectable> createState() => _ButtonSelectableState();
}

class _ButtonSelectableState extends State<ButtonSelectable> with SingleTickerProviderStateMixin {
  Animation<Color?>? _animation;
  late AnimationController _controller;

  final ValueNotifier<bool> _colorContextReady = ValueNotifier<bool>(false);

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      upperBound: 0.5,
      vsync: this,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animation = ColorTween(
        begin: ColorsExt.background(context),
        end: ColorsExt.grey200(context),
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
        widget.onPressed();
      },
      onLongPressCancel: () => _controller.reverse(),
      onLongPressEnd: (_) => _controller.reverse(),
      child: ValueListenableBuilder(
          valueListenable: _colorContextReady,
          builder: (context, bool ready, child) {
            if (!ready) {
              return const SizedBox();
            }

            return Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: widget.selected ? ColorsExt.grey200(context) : ColorsExt.background(context),
              ),
              child: AnimatedBuilder(
                animation: _animation!,
                builder: (_, child) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimension.paddingS),
                  child: Material(
                    color: ColorsExt.background(context),
                    child: Material(
                      color: widget.selected ? ColorsExt.grey200(context) : ColorsExt.background(context),
                      child: Row(
                        children: [
                          LeadingIcon(leading: widget.leading),
                          Expanded(
                            child: Text(widget.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: widget.titleColor ?? ColorsExt.grey800(context),
                                    )),
                          ),
                          Visibility(
                            visible: widget.trailing != null,
                            replacement: const SizedBox(),
                            child: Row(
                              children: [
                                widget.trailing!,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
