import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/style/colors.dart';

class ButtonAction extends StatelessWidget {
  final Color backColor;
  final Color topColor;
  final String icon;
  final String? label;
  final String? bottomLabel;
  final Function() click;

  const ButtonAction({
    Key? key,
    required this.backColor,
    required this.topColor,
    required this.icon,
    this.label,
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
              width: label == null || label!.isEmpty ? 40 : 86,
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
                        width: 21,
                        height: 21,
                      ),
                    ),
                    Flexible(
                      child: Builder(builder: (context) {
                        if (label == null || label!.isEmpty) {
                          return const SizedBox();
                        }

                        return Row(
                          children: [
                            const SizedBox(width: 4.5),
                            Flexible(
                              child: Text(
                                label!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: topColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
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
          style: TextStyle(
              fontSize: 11,
              color: ColorsExt.grey2(context),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
