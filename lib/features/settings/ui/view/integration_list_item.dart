import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';

class IntegrationListItem extends StatefulWidget {
  final String title;
  final Function() onPressed;
  final Widget leadingWidget;
  final EdgeInsets insets;
  final BorderRadius borderRadius;
  final bool enabled;
  final bool useSvgColor;
  final Widget? trailingWidget;
  final MainAxisAlignment? textMainAxisAlignment;
  final String? identifier;

  const IntegrationListItem({
    Key? key,
    required this.title,
    required this.onPressed,
    this.enabled = true,
    this.useSvgColor = false,
    this.trailingWidget,
    this.textMainAxisAlignment,
    required this.leadingWidget,
    this.identifier,
    this.insets = const EdgeInsets.symmetric(horizontal: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);

  @override
  State<IntegrationListItem> createState() => _IntegrationListItemState();
}

class _IntegrationListItemState extends State<IntegrationListItem> with SingleTickerProviderStateMixin {
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
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
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
                          borderRadius: widget.borderRadius,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animation!,
                        builder: (_, child) => Container(
                          margin: widget.insets,
                          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                          decoration: BoxDecoration(
                            borderRadius: widget.borderRadius,
                            color: _animation!.value,
                          ),
                          child: Row(
                            children: [
                              _buildLeadingIcon(),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.title,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: (widget.enabled
                                                  ? ColorsExt.grey2(context)
                                                  : ColorsExt.grey3(context)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Builder(builder: (context) {
                                      if (widget.identifier == null || widget.identifier!.isEmpty) {
                                        return const SizedBox();
                                      }

                                      return Column(
                                        children: [
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 5,
                                                backgroundColor: ColorsExt.green(context),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                  child: Text(
                                                widget.identifier!,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: ColorsExt.grey3(context),
                                                  fontSize: 13,
                                                ),
                                              )),
                                            ],
                                          )
                                        ],
                                      );
                                    })
                                  ],
                                ),
                              ),
                              Builder(builder: (context) {
                                if (widget.trailingWidget != null) {
                                  return widget.trailingWidget!;
                                }

                                return SvgPicture.asset(
                                  "assets/images/icons/_common/chevron_right.svg",
                                  width: 20,
                                  height: 20,
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
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Row(
      children: [
        const SizedBox(width: 16),
        SizedBox(width: 32, height: 32, child: widget.leadingWidget),
        const SizedBox(width: 16),
      ],
    );
  }
}