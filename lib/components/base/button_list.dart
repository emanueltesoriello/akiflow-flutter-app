import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';

enum ButtonListPosition { single, top, center, bottom }

class ButtonList extends StatefulWidget {
  final String title;
  final Function() onPressed;
  final Widget? leadingWidget;
  final ButtonListPosition position;

  const ButtonList({
    Key? key,
    required this.title,
    required this.onPressed,
    this.leadingWidget,
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
              builder: (_, child) => Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius(context),
                  color: _animation!.value,
                  border: Border.all(
                    color: ColorsExt.grey5(context),
                  ),
                ),
                child: Padding(
                  padding: paddingWidget(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                      child: Row(
                        children: [
                          _buildLeadingIcon(),
                          Expanded(
                            child: Text(
                              widget.title,
                              textAlign: widget.leadingWidget == null
                                  ? TextAlign.center
                                  : TextAlign.left,
                              style: TextStyle(
                                fontSize: 17,
                                color: ColorsExt.grey2(context),
                              ),
                            ),
                          ),
                          Builder(builder: (context) {
                            if (widget.leadingWidget == null) {
                              return const SizedBox();
                            }

                            return const Icon(SFSymbols.chevron_right);
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
    if (widget.leadingWidget == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        SizedBox(height: 20, width: 20, child: widget.leadingWidget),
        const SizedBox(width: 8),
      ],
    );
  }

  EdgeInsets paddingWidget(BuildContext context) {
    switch (widget.position) {
      case ButtonListPosition.single:
        return const EdgeInsets.all(1);
      case ButtonListPosition.top:
        return const EdgeInsets.only(top: 1, left: 1, right: 1);
      case ButtonListPosition.center:
        return const EdgeInsets.only(left: 1, right: 1);
      case ButtonListPosition.bottom:
        return const EdgeInsets.only(bottom: 1, left: 1, right: 1);
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

  BoxDecoration decoration(BuildContext context) {
    switch (widget.position) {
      case ButtonListPosition.single:
        return BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(radius),
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ));
      case ButtonListPosition.top:
        return BoxDecoration(
          // borderRadius: BorderRadius.only(
          //   topLeft: Radius.circular(radius),
          //   topRight: Radius.circular(radius),
          // ),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
            left: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
            right: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
          ),
        );
      case ButtonListPosition.center:
        return BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(radius),
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ));
      case ButtonListPosition.bottom:
        return BoxDecoration(
          // borderRadius: BorderRadius.only(
          //   bottomLeft: Radius.circular(radius),
          //   bottomRight: Radius.circular(radius),
          // ),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
            left: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
            right: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            ),
          ),
        );
    }
  }
}
