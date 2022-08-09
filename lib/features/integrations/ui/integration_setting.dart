import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/theme.dart';

class IntegrationSetting extends StatefulWidget {
  final String title;
  final String subtitle;
  final Function() onPressed;
  final Widget? trailingWidget;

  const IntegrationSetting({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.trailingWidget,
  }) : super(key: key);

  @override
  State<IntegrationSetting> createState() => _IntegrationSettingState();
}

class _IntegrationSettingState extends State<IntegrationSetting> with SingleTickerProviderStateMixin {
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
                builder: (_, child) => AnimatedBuilder(
                  animation: _animation!,
                  builder: (_, child) => Container(
                    margin: const EdgeInsets.all(1),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: ColorsExt.grey5(context),
                          offset: const Offset(0, 2),
                          blurRadius: 1,
                        ),
                      ],
                      color: _animation!.value,
                    ),
                    child: Row(
                      children: [
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
                                    style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context)),
                                  )),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    widget.subtitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: ColorsExt.grey3(context),
                                      fontSize: 13,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
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
              );
            }),
      ),
    );
  }
}
