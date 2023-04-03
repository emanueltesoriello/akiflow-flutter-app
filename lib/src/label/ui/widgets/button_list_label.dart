import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/button_list.dart';

class ButtonListLabel extends StatefulWidget {
  final String title;
  final Function() onPressed;
  final Widget? leading;
  final ButtonListPosition position;
  final bool showShevron;
  final String? leadingTextIconAsset;

  const ButtonListLabel({
    Key? key,
    required this.title,
    required this.onPressed,
    this.leading,
    this.position = ButtonListPosition.single,
    this.showShevron = true,
    this.leadingTextIconAsset,
  }) : super(key: key);

  @override
  State<ButtonListLabel> createState() => _View();
}

class _View extends State<ButtonListLabel> with SingleTickerProviderStateMixin {
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
              return const SizedBox();
            }

            return AnimatedBuilder(
              animation: _animation!,
              builder: (_, child) => AnimatedBuilder(
                animation: _animation!,
                builder: (_, child) => Container(
                  padding: const EdgeInsets.all(Dimension.padding),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(Dimension.radius),
                    ),
                    color: _animation!.value,
                  ),
                  child: Row(
                    children: [
                      _buildLeading(),
                      Expanded(
                        child: Row(
                          mainAxisAlignment:
                              widget.leading == null ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                widget.title,
                                textAlign: widget.leading == null ? TextAlign.center : TextAlign.left,
                                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                                      color: ColorsExt.grey2(context),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Builder(builder: (context) {
                        if (widget.leading == null) {
                          return const SizedBox();
                        }

                        if (widget.showShevron == false) {
                          return const SizedBox();
                        }

                        return SvgPicture.asset(
                          Assets.images.icons.common.chevronRightSVG,
                          width: Dimension.chevronIconSize,
                          height: Dimension.chevronIconSize,
                          color: ColorsExt.grey3(context),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildLeading() {
    if (widget.leading == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        widget.leading!,
        const SizedBox(width: Dimension.paddingS),
      ],
    );
  }
}
