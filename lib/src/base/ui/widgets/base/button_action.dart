import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

class ButtonAction extends StatelessWidget {
  final Color backColor;
  final Color topColor;
  final String icon;
  final String? bottomLabel;
  final Function() click;

  const ButtonAction({
    Key? key,
    required this.backColor,
    required this.topColor,
    required this.icon,
    this.bottomLabel,
    required this.click,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: click,
      child: SizedBox(
        height: bottomLabel != null && bottomLabel!.isNotEmpty ? 56 : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: backColor,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SvgPicture.asset(
                        icon,
                        color: topColor,
                        width: Dimension.defaultIconSize,
                        height: Dimension.defaultIconSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _bottomLabel(context),
          ],
        ),
      ),
    );
  }

  Widget _bottomLabel(BuildContext context) {
    if (bottomLabel == null || bottomLabel!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 2),
        Text(
          bottomLabel!,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: ColorsExt.grey2(context), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
