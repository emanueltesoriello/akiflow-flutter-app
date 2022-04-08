import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile/style/colors.dart';

class ButtonSelectable extends StatefulWidget {
  final String title;
  final Function() onPressed;
  final IconData? leading;
  final Widget? trailing;
  final bool selected;

  const ButtonSelectable({
    Key? key,
    required this.title,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.selected = false,
  }) : super(key: key);

  @override
  State<ButtonSelectable> createState() => _ButtonSelectableState();
}

class _ButtonSelectableState extends State<ButtonSelectable>
    with SingleTickerProviderStateMixin {
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

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _animation = ColorTween(
        begin: Theme.of(context).backgroundColor,
        end: ColorsExt.grey5(context),
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
        widget.onPressed.call();
      },
      onLongPressCancel: () => _controller.reverse(),
      onLongPressEnd: (_) => _controller.reverse(),
      child: ValueListenableBuilder(
          valueListenable: _colorContextReady,
          builder: (context, bool ready, child) {
            if (!ready) {
              return Container();
            }

            return Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: widget.selected
                    ? ColorsExt.grey5(context)
                    : Colors.transparent,
              ),
              child: AnimatedBuilder(
                animation: _animation!,
                builder: (_, child) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    color: _animation!.value,
                    child: Container(
                      color: widget.selected
                          ? ColorsExt.grey5(context)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          _buildLeadingIcon(),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 17,
                                color: ColorsExt.grey2(context),
                              ),
                            ),
                          ),
                          Builder(builder: (context) {
                            if (widget.trailing == null) {
                              return const SizedBox();
                            }

                            return Row(
                              children: [
                                widget.trailing!,
                              ],
                            );
                          }),
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

  Widget _buildLeadingIcon() {
    if (widget.leading == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        Icon(
          widget.leading!,
          size: 24,
          color: ColorsExt.grey2(context),
        ),
        const SizedBox(width: 10.5),
      ],
    );
  }
}
