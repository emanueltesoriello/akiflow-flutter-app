import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';

enum ButtonListPosition { single, top, center, bottom }

class ButtonList extends StatefulWidget {
  final String title;
  final Function() onPressed;
  final IconData? leading;
  final Color? leadingColor;
  final ButtonListPosition position;

  const ButtonList({
    Key? key,
    required this.title,
    required this.onPressed,
    this.leading,
    this.leadingColor,
    this.position = ButtonListPosition.single,
  }) : super(key: key);

  @override
  State<ButtonList> createState() => _ButtonListState();
}

class _ButtonListState extends State<ButtonList>
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

            return AnimatedBuilder(
              animation: _animation!,
              builder: (_, child) => IntrinsicHeight(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ColorsExt.grey5(context),
                        borderRadius: borderRadius(context),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animation!,
                      builder: (_, child) => Container(
                        margin: margin(context),
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                        decoration: BoxDecoration(
                          borderRadius: borderRadius(context),
                          color: _animation!.value,
                        ),
                        child: Row(
                          children: [
                            _buildLeadingIcon(),
                            Expanded(
                              child: Text(
                                widget.title,
                                textAlign: widget.leading == null
                                    ? TextAlign.center
                                    : TextAlign.left,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: ColorsExt.grey2(context),
                                ),
                              ),
                            ),
                            Builder(builder: (context) {
                              if (widget.leading == null) {
                                return const SizedBox();
                              }

                              return Icon(
                                SFSymbols.chevron_right,
                                size: 20,
                                color: ColorsExt.grey3(context),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
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
          color: widget.leadingColor ?? ColorsExt.grey2(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  EdgeInsets margin(BuildContext context) {
    switch (widget.position) {
      case ButtonListPosition.single:
        return const EdgeInsets.all(1);
      case ButtonListPosition.top:
        return const EdgeInsets.only(left: 1, top: 1, right: 1);
      case ButtonListPosition.center:
        return const EdgeInsets.all(1);
      case ButtonListPosition.bottom:
        return const EdgeInsets.only(left: 1, bottom: 1, right: 1);
    }
  }

  BorderRadius borderRadius(BuildContext context) {
    switch (widget.position) {
      case ButtonListPosition.single:
        return const BorderRadius.all(
          Radius.circular(radius),
        );
      case ButtonListPosition.top:
        return const BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        );
      case ButtonListPosition.center:
        return BorderRadius.zero;
      case ButtonListPosition.bottom:
        return const BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
    }
  }
}
