import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/space.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/theme.dart';

class GoogleButton extends StatefulWidget {
  final Function()? onPressed;

  const GoogleButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton>
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
        end: Theme.of(context).backgroundColor,
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
                  color: ColorsExt.grey5(context),
                  width: border,
                ),
                color: _animation!.value,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: Text(
                      t.onboarding.sign_in_with_google,
                      style: TextStyle(
                        fontSize: 17,
                        color: ColorsExt.grey2_5(context),
                      ),
                    )),
                    const Space(8),
                    SvgPicture.asset(
                      'assets/images/icons/google/search.svg',
                      height: 20,
                      width: 20,
                    ),
                  ],
                )),
              ),
            ),
          );
        },
      ),
    );
  }
}
